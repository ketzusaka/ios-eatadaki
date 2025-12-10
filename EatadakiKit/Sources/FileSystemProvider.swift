import Foundation

public protocol FileSystemProvider {
    func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL
}

extension FileManager: FileSystemProvider {}

#if DEBUG
public class FakeFileSystemProvider: FileSystemProvider {
        
    public init(_ configure: (FakeFileSystemProvider) -> Void = { _ in }) {
        configure(self)
    }
    
    public private(set) var invocationsUrlForInAppropriateForCreate: [(directory: FileManager.SearchPathDirectory, domain: FileManager.SearchPathDomainMask, appropriateFor: URL?, create: Bool)] = []
    public var stubUrlForInAppropriateForCreate: ((FileManager.SearchPathDirectory, FileManager.SearchPathDomainMask, URL?, Bool) throws -> URL) = { directory, domain, url, shouldCreate in
        URL(fileURLWithPath: "/tmp/fake_application_support")
    }
    
    public func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL {
        invocationsUrlForInAppropriateForCreate.append((directory, domain, url, shouldCreate))
        return try stubUrlForInAppropriateForCreate(directory, domain, url, shouldCreate)
    }

}
#endif
