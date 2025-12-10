import Foundation
import Pour
import Testing

@Suite("Bartender Tests")
struct BartenderTests {
    
    @Test("Same key returns same instance")
    func testSameKeyReturnsSameInstance() {
        let bartender = Bartender()
        var callCount = 0
        
        let instance1 = bartender.shared(key: "test-key") {
            callCount += 1
            return TestObject()
        }
        
        let instance2 = bartender.shared(key: "test-key") {
            callCount += 1
            return TestObject()
        }
        
        #expect(instance1 === instance2)
        #expect(callCount == 1)
    }
    
    @Test("Different keys return different instances")
    func testDifferentKeysReturnDifferentInstances() {
        let bartender = Bartender()
        
        let instance1 = bartender.shared(key: "key-1") {
            TestObject()
        }
        
        let instance2 = bartender.shared(key: "key-2") {
            TestObject()
        }
        
        #expect(instance1 !== instance2)
    }
    
    @Test("Default key uses file and line")
    func testDefaultKeyUsesFileAndLine() {
        let bartender = Bartender()
        
        // These should be different instances because they're on different lines
        let instance1 = bartender.shared { TestObject() }
        let instance2 = bartender.shared { TestObject() }
        
        // They should be different because the default key includes the line number
        #expect(instance1 !== instance2)
    }
    
    @Test("Same default key on same line returns same instance")
    func testSameDefaultKeyOnSameLine() {
        let bartender = Bartender()
        
        // Call with explicit same key to simulate same line
        let instance1 = bartender.shared(key: "same-line") { TestObject() }
        let instance2 = bartender.shared(key: "same-line") { TestObject() }
        
        #expect(instance1 === instance2)
    }
    
    @Test("Different Bartender instances have separate caches")
    func testDifferentBartenderInstancesHaveSeparateCaches() {
        let bartender1 = Bartender()
        let bartender2 = Bartender()
        
        let instance1 = bartender1.shared(key: "shared-key") {
            TestObject()
        }
        
        let instance2 = bartender2.shared(key: "shared-key") {
            TestObject()
        }
        
        // Different bartenders should have different caches
        #expect(instance1 !== instance2)
    }
    
    @Test("Factory closure only called once per key")
    func testFactoryClosureOnlyCalledOnce() {
        let bartender = Bartender()
        var callCount = 0
        
        _ = bartender.shared(key: "count-test") {
            callCount += 1
            return TestObject()
        }
        
        _ = bartender.shared(key: "count-test") {
            callCount += 1
            return TestObject()
        }
        
        _ = bartender.shared(key: "count-test") {
            callCount += 1
            return TestObject()
        }
        
        #expect(callCount == 1)
    }
    
    @Test("Works with different types")
    func testWorksWithDifferentTypes() {
        let bartender = Bartender()
        
        let stringInstance = bartender.shared(key: "string-key") {
            "test-string"
        }
        
        let intInstance = bartender.shared(key: "int-key") {
            42
        }
        
        let objectInstance = bartender.shared(key: "object-key") {
            TestObject()
        }
        
        #expect(stringInstance == "test-string")
        #expect(intInstance == 42)
        #expect(objectInstance is TestObject)
    }
    
    @Test("Thread safety - concurrent access")
    func testThreadSafety() async {
        let bartender = Bartender()
        let key = "concurrent-key"
        
        await withTaskGroup(of: TestObject?.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    bartender.shared(key: key) {
                        TestObject()
                    }
                }
            }
            
            var instances: [TestObject] = []
            for await instance in group {
                if let instance {
                    instances.append(instance)
                }
            }
            
            // All instances should be the same (same reference)
            let firstInstance = instances.first
            for instance in instances {
                #expect(instance === firstInstance)
            }
        }
    }
    
    @Test("Empty string key works")
    func testEmptyStringKey() {
        let bartender = Bartender()
        
        let instance1 = bartender.shared(key: "") {
            TestObject()
        }
        
        let instance2 = bartender.shared(key: "") {
            TestObject()
        }
        
        #expect(instance1 === instance2)
    }
}

// MARK: - Test Helpers

private class TestObject {
    let id = UUID()
}
