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
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    TextField("Search prompts...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)

                List(filteredPrompts, id: \.id, selection: $viewModel.selectedPrompt) { prompt in
                    PromptListItemView(prompt: prompt)
                        .tag(prompt)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.deletePrompt(prompt)
                                }
                            }
                        }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
            }
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            // Detail View
            if let selected = viewModel.selectedPrompt {
                SafePromptDetailView(prompt: selected)
            } else {
                PromptEmptyStateView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewPrompt = true }) {
                    Label("New Prompt", systemImage: "plus")
                }
                .help("Create a new prompt")
            }
        }
        .navigationTitle("PromptManager")
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            viewModel.loadPrompts()
        }
        .sheet(isPresented: $showingNewPrompt) {
            NewPromptView(viewModel: viewModel, isPresented: $showingNewPrompt)
        }
    }

    private var filteredPrompts: [SafePrompt] {
        if searchText.isEmpty {
            return viewModel.prompts
        } else {
            return viewModel.prompts.filter { prompt in
                prompt.title.localizedCaseInsensitiveContains(searchText) ||
                prompt.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct PromptListItemView: View {
    let prompt: SafePrompt

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(prompt.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(prompt.content)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SafePromptDetailView: View {
    let prompt: SafePrompt

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(prompt.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(prompt.content, forType: .string)
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.bordered)
                    .help("Copy prompt to clipboard")
                }

                Text("Created \(prompt.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(prompt.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
                )
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct PromptEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble.rtl")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundColor(.secondary.opacity(0.6))

            VStack(spacing: 8) {
                Text("No Prompt Selected")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("Choose a prompt from the sidebar to view its details")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct NewPromptView: View {
    @ObservedObject var viewModel: SafePromptViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Title")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    TextField("Enter a descriptive title...", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 15))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Content")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    TextEditor(text: $content)
                        .font(.system(size: 14))
                        .frame(minHeight: 250)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(NSColor.textBackgroundColor))
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if content.isEmpty {
                                    VStack {
                                        HStack {
                                            Text("Write your prompt here...")
                                                .foregroundColor(.secondary.opacity(0.7))
                                                .font(.system(size: 14))
                                                .padding(.leading, 16)
                                                .padding(.top, 20)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        )
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("New Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.addPrompt(title: title, content: content)
                        }
                        isPresented = false
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                             content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .frame(minWidth: 520, minHeight: 480)
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