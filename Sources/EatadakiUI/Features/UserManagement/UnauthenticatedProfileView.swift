import SwiftUI

struct UnauthenticatedProfileView: View {
    var body: some View {
        List {
            Text("Please log in or register")
                .font(.headline)
        }
        .navigationTitle("Profile")
    }
}
