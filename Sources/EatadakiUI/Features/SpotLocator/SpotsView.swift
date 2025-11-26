import SwiftUI

public struct SpotsView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Text("Spots")
                    .font(.headline)
            }
            .navigationTitle("Eatadaki")
        }
    }
}
