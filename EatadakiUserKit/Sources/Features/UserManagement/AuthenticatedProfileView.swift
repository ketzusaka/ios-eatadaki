import SwiftUI

public struct AuthenticatedProfileView: View {
    public init() {}
    
    public var body: some View {
        List {
            Text("Profile")
                .font(.headline)
        }
        .navigationTitle("Profile")
    }
}
