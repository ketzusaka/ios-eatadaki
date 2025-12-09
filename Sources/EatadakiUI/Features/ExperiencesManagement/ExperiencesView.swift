import SwiftUI

public struct ExperiencesView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Text("Experiences")
                    .font(.headline)
            }
            .navigationTitle("Experiences")
        }
    }
}
