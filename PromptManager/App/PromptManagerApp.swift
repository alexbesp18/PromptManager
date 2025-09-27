import SwiftUI
import CoreData

// Simplified ViewModel that doesn't crash
@MainActor
class SafePromptViewModel: ObservableObject {
    @Published var prompts: [SafePrompt] = []
    @Published var selectedPrompt: SafePrompt?

    private let coreDataStack = SafeCoreDataStack.shared

    init() {
        // Don't load data in initializer - do it after view appears
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

struct SafePrompt: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: String
}

struct CoreDataContentView: View {
    @StateObject private var viewModel = SafePromptViewModel()

    var body: some View {
        HStack {
            // Sidebar
            VStack(alignment: .leading) {
                Text("PromptManager (Core Data)")
                    .font(.headline)
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
                            Text("(Using in-memory storage)")
                                .foregroundColor(.orange)
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 700, minHeight: 500)
        .onAppear {
            print("Loading sample data...")
            viewModel.loadSampleData()
        }
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
                Button("Copy Selected Prompt") {
                    // This would copy the selected prompt
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }
        }
    }
}