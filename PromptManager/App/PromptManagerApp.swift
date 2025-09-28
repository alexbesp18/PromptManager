import SwiftUI
import CoreData

// Simplified ViewModel that doesn't crash
@MainActor
class SafePromptViewModel: ObservableObject {
    @Published var prompts: [SafePrompt] = []
    @Published var selectedPrompt: SafePrompt?

    private let coreDataStack = SafeCoreDataStack.shared
    private let saveURL: URL

    init() {
        // Set up save location in Documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.saveURL = documentsPath.appendingPathComponent("PromptManager").appendingPathExtension("json")
        print("📂 Save location: \(saveURL.path)")
    }

    func addPrompt(title: String, content: String) {
        let newPrompt = SafePrompt(title: title, content: content)
        prompts.append(newPrompt)
        selectedPrompt = newPrompt
        savePrompts()
        print("✅ Added new prompt: \(title)")
    }

    func deletePrompt(_ prompt: SafePrompt) {
        prompts.removeAll { $0.id == prompt.id }
        if selectedPrompt?.id == prompt.id {
            selectedPrompt = prompts.first
        }
        savePrompts()
        print("✅ Deleted prompt: \(prompt.title)")
    }

    private func savePrompts() {
        do {
            let data = try JSONEncoder().encode(prompts)
            try data.write(to: saveURL)
            print("💾 Saved \(prompts.count) prompts to: \(saveURL.path)")
        } catch {
            print("❌ Failed to save prompts to \(saveURL.path): \(error)")
        }
    }

    func loadPrompts() {
        print("🔍 Attempting to load prompts from: \(saveURL.path)")
        do {
            let data = try Data(contentsOf: saveURL)
            prompts = try JSONDecoder().decode([SafePrompt].self, from: data)
            print("📂 Successfully loaded \(prompts.count) prompts from disk")
        } catch {
            print("📂 No saved prompts found (\(error.localizedDescription)), loading sample data")
            loadSampleData()
            savePrompts()
        }
    }

    func loadSampleData() {
        // Simple in-memory data - Core Data entities are corrupted, so avoiding them
        prompts = [
            SafePrompt(title: "Creative Writing", content: "Write a story about [TOPIC]. Include compelling characters, an engaging plot, vivid descriptions, and a satisfying conclusion."),
            SafePrompt(title: "Code Review", content: "Please review the following code and provide feedback on:\n\n1. Code quality and readability\n2. Performance optimizations\n3. Security considerations\n4. Best practices\n5. Potential bugs or issues"),
            SafePrompt(title: "Email Draft", content: "Draft a professional email for [PURPOSE]. Keep it concise, clear, and appropriate for the recipient."),
            SafePrompt(title: "Meeting Summary", content: "Create a summary of the meeting including:\n- Key discussion points\n- Decisions made\n- Action items\n- Next steps"),
            SafePrompt(title: "Data Analysis", content: "Analyze the following data and provide insights:\n\n**Data:** [DATASET]\n\n**Analysis Requirements:**\n- Key trends and patterns\n- Statistical summaries\n- Potential correlations\n- Recommendations"),
            SafePrompt(title: "Bug Report", content: "**Bug Report**\n\n**Issue:** [DESCRIPTION]\n**Steps to Reproduce:**\n1. [STEP_1]\n2. [STEP_2]\n3. [STEP_3]\n\n**Expected:** [EXPECTED_BEHAVIOR]\n**Actual:** [ACTUAL_BEHAVIOR]\n**Environment:** [DETAILS]")
        ]
        print("✅ Loaded \(prompts.count) sample prompts successfully!")
    }
}

struct SafePrompt: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date

    init(title: String, content: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct CoreDataContentView: View {
    @StateObject private var viewModel = SafePromptViewModel()
    @State private var showingNewPrompt = false

    var body: some View {
        HStack {
            // Sidebar
            VStack(alignment: .leading) {
                HStack {
                    Text("PromptManager")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingNewPrompt = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    .help("Add New Prompt")
                }
                .padding()

                List(viewModel.prompts, id: \.id, selection: $viewModel.selectedPrompt) { prompt in
                    VStack(alignment: .leading) {
                        Text(prompt.title)
                            .font(.headline)
                        Text(prompt.content)
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(prompt)
                    .contextMenu {
                        Button("Delete") {
                            viewModel.deletePrompt(prompt)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
            }
            .frame(minWidth: 300)

            Divider()

            // Detail
            VStack {
                if let selected = viewModel.selectedPrompt {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(selected.title)
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Button("Copy") {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(selected.content, forType: .string)
                            }
                        }

                        ScrollView {
                            Text(selected.content)
                                .textSelection(.enabled)
                                .padding()
                                .background(Color(.textBackgroundColor))
                                .cornerRadius(8)
                        }

                        Spacer()
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Select a prompt to view details")
                            .foregroundColor(.secondary)
                            .font(.title2)
                        VStack {
                            Text("✅ App running successfully!")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("(Using persistent JSON storage)")
                                .foregroundColor(.green)
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 700, minHeight: 500)
        .onAppear {
            print("Loading prompts from disk...")
            viewModel.loadPrompts()
        }
        .sheet(isPresented: $showingNewPrompt) {
            NewPromptView(viewModel: viewModel, isPresented: $showingNewPrompt)
        }
    }
}

struct NewPromptView: View {
    @ObservedObject var viewModel: SafePromptViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var content = ""

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

                Spacer()
            }
            .padding()
            .navigationTitle("New Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.addPrompt(title: title, content: content)
                        isPresented = false
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

@main
struct PromptManagerApp: App {
    var body: some Scene {
        WindowGroup {
            CoreDataContentView()
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Prompt") {
                    // Trigger new prompt creation
                }
                .keyboardShortcut("n", modifiers: [.command])

                Button("Copy Selected Prompt") {
                    // This would copy the selected prompt
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }
        }
    }
}