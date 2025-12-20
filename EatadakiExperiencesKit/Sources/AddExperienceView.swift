import EatadakiUI
import SwiftUI

public typealias AddExperienceViewDependencies = AddExperienceViewModelDependencies

public struct AddExperienceView: View {
    @Environment(ThemeManager.self) var themeManager
    @Environment(\.colorScheme) var colorScheme

    @State var viewModel: AddExperienceViewModel
    @Binding var isPresented: Bool

    public init(
        dependencies: AddExperienceViewDependencies,
        spotId: UUID,
        isPresented: Binding<Bool>,
    ) {
        self.viewModel = AddExperienceViewModel(
            dependencies: dependencies,
            spotId: spotId,
        )
        self._isPresented = isPresented
    }

    public var body: some View {
        let theme = themeManager.tokens(for: colorScheme)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Name")
                        .headlineTextStyling(using: theme)

                    TextField("We recommend matching the menu!", text: $viewModel.name)
                }

                Spacer(minLength: 24)

                VStack(alignment: .leading) {
                    Text("Description")
                        .headlineTextStyling(using: theme)

                    TextEditor(text: $viewModel.description)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 150)

                    Text("A description is optional.")
                        .captionTextStyling(using: theme)
                }

                Spacer(minLength: 24)

                VStack(alignment: .leading) {
                    Text("Rating")
                        .headlineTextStyling(using: theme)

                    Toggle(isOn: $viewModel.showAddRating) {
                        Text("Include a Rating?")
                    }
                }

                Spacer(minLength: 24)

                if viewModel.showAddRating {
                    EditExperienceRatingView(
                        rating: $viewModel.experienceRating,
                        note: $viewModel.experienceNote,
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: viewModel.showAddRating)
            .padding()
            .navigationTitle("Add Experience")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        await viewModel.saveExperience()
                        isPresented = false
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    let dependencies = FakeAddExperienceViewModelDependencies()

    NavigationStack {
        AddExperienceView(
            dependencies: dependencies,
            spotId: UUID(),
            isPresented: .constant(true),
        )
        .environment(ThemeManager())
    }
}
#endif
