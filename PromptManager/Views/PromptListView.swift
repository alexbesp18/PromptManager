import SwiftUI

struct PromptListView: View {
    @ObservedObject var viewModel: PromptViewModel
    @Binding var showingNewPrompt: Bool
    @State private var showingNewCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Prompt Manager")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showingNewPrompt = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                }

                SearchBar(text: $viewModel.searchText)

                FilterSection(viewModel: viewModel, showingNewCategory: $showingNewCategory)
            }
            .padding()

            Divider()

            List(viewModel.filteredPrompts, id: \.id, selection: $viewModel.selectedPrompt) { prompt in
                PromptRowView(prompt: prompt, viewModel: viewModel)
                    .tag(prompt)
            }
            .listStyle(SidebarListStyle())
            .onDeleteCommand {
                if let selectedPrompt = viewModel.selectedPrompt {
                    viewModel.deletePrompt(selectedPrompt)
                }
            }
            .onKeyPress(.space) {
                if let selectedPrompt = viewModel.selectedPrompt {
                    viewModel.toggleFavorite(selectedPrompt)
                    return .handled
                }
                return .ignored
            }
        }
        .frame(minWidth: 250)
        .alert("New Category", isPresented: $showingNewCategory) {
            TextField("Category name", text: $newCategoryName)
            Button("Create") {
                if !newCategoryName.isEmpty {
                    viewModel.addCategory(name: newCategoryName)
                    newCategoryName = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newCategoryName = ""
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search prompts...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct FilterSection: View {
    @ObservedObject var viewModel: PromptViewModel
    @Binding var showingNewCategory: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
                    .toggleStyle(SwitchToggleStyle())
            }

            HStack {
                Text("Category:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { showingNewCategory = true }) {
                    Image(systemName: "plus.circle")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }

            Picker("Category", selection: $viewModel.selectedCategory) {
                Text("All Categories").tag(Category?.none)
                ForEach(viewModel.categories, id: \.id) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct PromptRowView: View {
    let prompt: Prompt
    @ObservedObject var viewModel: PromptViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(prompt.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if prompt.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Text(prompt.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if !prompt.tags.isEmpty {
                HStack {
                    ForEach(prompt.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                    if prompt.tags.count > 3 {
                        Text("+\(prompt.tags.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let category = prompt.category {
                Text(category.name)
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: { viewModel.toggleFavorite(prompt) }) {
                Label(prompt.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: prompt.isFavorite ? "heart.slash" : "heart")
            }
            Button(action: { viewModel.deletePrompt(prompt) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}