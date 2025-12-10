import SwiftUI

public struct UnauthenticatedProfileView: View {
    public init() {}
    
    public var body: some View {
        List {
            Text("Please log in or register")
                .font(.headline)
        }
        .navigationTitle("Profile")
    }
}
