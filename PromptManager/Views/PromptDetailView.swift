import SwiftUI

struct PromptDetailView: View {
    let prompt: Prompt
    @ObservedObject var viewModel: PromptViewModel
    @State private var showingEditView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(prompt.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: { viewModel.toggleFavorite(prompt) }) {
                            Image(systemName: prompt.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(prompt.isFavorite ? .red : .secondary)
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)

                        Button("Edit") {
                            showingEditView = true
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    if let category = prompt.category {
                        Text(category.name)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                    }

                    if !prompt.tags.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), alignment: .leading, spacing: 8) {
                            ForEach(prompt.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Content")
                        .font(.headline)

                    SelectableText(text: prompt.content)
                        .font(.body)
                        .padding()
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Metadata")
                        .font(.headline)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Created:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(prompt.createdAt, style: .date)
                                .font(.caption)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Updated:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(prompt.updatedAt, style: .date)
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingEditView) {
            PromptEditView(prompt: prompt, viewModel: viewModel, isPresented: $showingEditView)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Copy Content") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(prompt.content, forType: .string)
                    }
                    Button("Export as JSON") {
                        exportPromptAsJSON()
                    }
                    Divider()
                    Button("Delete", role: .destructive) {
                        viewModel.deletePrompt(prompt)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private func exportPromptAsJSON() {
        let exportData: [String: Any] = [
            "id": prompt.id.uuidString,
            "title": prompt.title,
            "content": prompt.content,
            "tags": prompt.tags,
            "category": prompt.category?.name ?? "",
            "isFavorite": prompt.isFavorite,
            "createdAt": ISO8601DateFormatter().string(from: prompt.createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: prompt.updatedAt)
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(jsonString, forType: .string)
        }
    }
}

struct SelectableText: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor.clear
        textView.string = text
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        nsView.string = text
    }
}