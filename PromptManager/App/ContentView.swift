import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PromptViewModel()
    @State private var showingNewPrompt = false

    var body: some View {
        VStack {
            Text("PromptManager")
                .font(.largeTitle)
                .padding()

            HStack {
                // Sidebar
                VStack {
                    Text("Prompts")
                        .font(.headline)
                        .padding()

                    List {
                        ForEach(viewModel.filteredPrompts, id: \.id) { prompt in
                            VStack(alignment: .leading) {
                                Text(prompt.title)
                                    .font(.headline)
                                Text(prompt.content)
                                    .font(.caption)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                            .onTapGesture {
                                viewModel.selectedPrompt = prompt
                            }
                        }
                    }
                }
                .frame(minWidth: 250)

                Divider()

                // Detail
                VStack {
                    if let selectedPrompt = viewModel.selectedPrompt {
                        VStack(alignment: .leading) {
                            Text(selectedPrompt.title)
                                .font(.title)
                                .padding()

                            ScrollView {
                                Text(selectedPrompt.content)
                                    .padding()
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("Select a prompt to view details")
                                .foregroundColor(.secondary)
                                .font(.title2)
                            Text("Use ⌘N to create a new prompt")
                                .foregroundColor(.secondary)
                                .opacity(0.7)
                                .font(.caption)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .sheet(isPresented: $showingNewPrompt) {
            PromptEditView(viewModel: viewModel, isPresented: $showingNewPrompt)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NewPrompt"))) { _ in
            showingNewPrompt = true
        }
        .onAppear {
            print("ContentView appeared successfully")
        }
    }
}