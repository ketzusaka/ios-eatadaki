import SwiftUI

public extension Button where Label == Text {
    init(_ titleKey: LocalizedStringKey, action: @MainActor @escaping () async -> Void) {
        self.init(titleKey) {
            Task { await action() }
        }
    }
}

public extension Button {
    init(action: @MainActor @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.init(action: { Task { await action() } }, label: label)
    }
}
