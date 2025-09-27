import SwiftUI

struct PromptEditView: View {
    let prompt: Prompt?
    @ObservedObject var viewModel: PromptViewModel
    @Binding var isPresented: Bool

    @State private var title: String
    @State private var content: String
    @State private var tagsText: String
    @State private var selectedCategory: Category?

    init(prompt: Prompt? = nil, viewModel: PromptViewModel, isPresented: Binding<Bool>) {
        self.prompt = prompt
        self.viewModel = viewModel
        self._isPresented = isPresented

        _title = State(initialValue: prompt?.title ?? "")
        _content = State(initialValue: prompt?.content ?? "")
        _tagsText = State(initialValue: prompt?.tags.joined(separator: ", ") ?? "")
        _selectedCategory = State(initialValue: prompt?.category)
    }

    private var isEditing: Bool {
        prompt != nil
    }

    private var tags: [String] {
        tagsText.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.headline)
                    TextField("Enter prompt title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                    TextEditor(text: $content)
                        .font(.body)
                        .frame(minHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.headline)
                    TextField("Enter tags separated by commas", text: $tagsText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("Separate multiple tags with commas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.headline)
                    Picker("Category", selection: $selectedCategory) {
                        Text("No Category").tag(Category?.none)
                        ForEach(viewModel.categories, id: \.id) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Spacer()
            }
            .padding()
            .navigationTitle(isEditing ? "Edit Prompt" : "New Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Create") {
                        savePrompt()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }

    private func savePrompt() {
        if let existingPrompt = prompt {
            viewModel.updatePrompt(
                existingPrompt,
                title: title,
                content: content,
                tags: tags,
                category: selectedCategory
            )
        } else {
            viewModel.addPrompt(
                title: title,
                content: content,
                tags: tags,
                category: selectedCategory
            )
        }
        isPresented = false
    }
}