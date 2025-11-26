import SwiftUI

public struct TastesView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Text("Tastes")
                    .font(.headline)
            }
            .navigationTitle("Tastes")
        }
    }
}
