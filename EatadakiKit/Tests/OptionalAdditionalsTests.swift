import EatadakiKit
import Foundation
import Testing

@Suite("OptionalAdditionals Tests")
struct OptionalAdditionalsTests {
    @Test("unwrapped returns value when optional is not nil")
    func testUnwrappedReturnsValueWhenNotNil() throws {
        let optionalInt: Int? = 42

        let value = try optionalInt.unwrapped

        #expect(value == 42)
    }

    @Test("unwrapped throws UnwrappingError.empty when optional is nil")
    func testUnwrappedThrowsWhenNil() throws {
        let optionalInt: Int? = nil

        #expect(throws: UnwrappingError.empty) {
            try optionalInt.unwrapped
        }
    }

    @Test("unwrapped works with String type")
    func testUnwrappedWithString() throws {
        let optionalString: String? = "test"

        let value = try optionalString.unwrapped

        #expect(value == "test")
    }

    @Test("unwrapped throws error with nil String")
    func testUnwrappedThrowsWithNilString() throws {
        let optionalString: String? = nil

        #expect(throws: UnwrappingError.empty) {
            try optionalString.unwrapped
        }
    }

    @Test("unwrapped works with custom types")
    func testUnwrappedWithCustomType() throws {
        struct TestStruct {
            let value: Int
        }

        let optionalStruct: TestStruct? = TestStruct(value: 100)

        let value = try optionalStruct.unwrapped

        #expect(value.value == 100)
    }

    @Test("unwrapped throws error with nil custom type")
    func testUnwrappedThrowsWithNilCustomType() throws {
        struct TestStruct {
            let value: Int
        }

        let optionalStruct: TestStruct? = nil

        #expect(throws: UnwrappingError.empty) {
            try optionalStruct.unwrapped
        }
    }
}

