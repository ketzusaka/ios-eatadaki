import SwiftUI

public extension View {
    func onFirstAppear(perform action: @escaping () async -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () async -> ()
    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            Task { await action() }
        }
    }
}

