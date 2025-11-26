import SwiftUI

public struct LoadingView: View {
    public init() {}

    public var body: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
}
