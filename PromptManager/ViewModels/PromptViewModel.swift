import Foundation
import CoreData
import SwiftUI
import AppKit
import UniformTypeIdentifiers

@MainActor
class PromptViewModel: ObservableObject {
    @Published var prompts: [Prompt] = []
    @Published var categories: [Category] = []
    @Published var searchText = ""
    @Published var selectedCategory: Category?
    @Published var selectedPrompt: Prompt?
    @Published var showFavoritesOnly = false

    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
        loadPrompts()
        loadCategories()
        addSampleDataIfNeeded()
    }

    private func addSampleDataIfNeeded() {
        if prompts.isEmpty && categories.isEmpty {
            addCategory(name: "Writing", color: "#FF6B6B")
            addCategory(name: "Coding", color: "#4ECDC4")
            addCategory(name: "Analysis", color: "#45B7D1")

            loadCategories()

            let writingCategory = categories.first { $0.name == "Writing" }
            let codingCategory = categories.first { $0.name == "Coding" }
            let analysisCategory = categories.first { $0.name == "Analysis" }

            addPrompt(
                title: "Creative Writing Starter",
                content: "Write a creative story about [TOPIC]. Include:\n- Compelling characters\n- An engaging plot\n- Vivid descriptions\n- A satisfying conclusion\n\nStyle: [STYLE]\nLength: [LENGTH]",
                tags: ["creative", "storytelling", "fiction"],
                category: writingCategory
            )

            addPrompt(
                title: "Code Review Assistant",
                content: "Please review the following code and provide feedback on:\n\n1. Code quality and readability\n2. Performance optimizations\n3. Security considerations\n4. Best practices\n5. Potential bugs or issues\n\n```\n[CODE_HERE]\n```",
                tags: ["code-review", "development", "best-practices"],
                category: codingCategory
            )

            addPrompt(
                title: "Data Analysis Helper",
                content: "Analyze the following data and provide insights:\n\n**Data:** [DATASET]\n\n**Analysis Requirements:**\n- Key trends and patterns\n- Statistical summaries\n- Potential correlations\n- Recommendations\n- Visualizations suggestions\n\n**Context:** [BUSINESS_CONTEXT]",
                tags: ["data", "analysis", "insights", "statistics"],
                category: analysisCategory
            )

            addPrompt(
                title: "Meeting Summary Template",
                content: "**Meeting Summary**\n\n**Date:** [DATE]\n**Attendees:** [ATTENDEES]\n**Purpose:** [PURPOSE]\n\n**Key Discussion Points:**\n- [POINT_1]\n- [POINT_2]\n- [POINT_3]\n\n**Decisions Made:**\n- [DECISION_1]\n- [DECISION_2]\n\n**Action Items:**\n- [ ] [ACTION_1] - Due: [DATE] - Owner: [PERSON]\n- [ ] [ACTION_2] - Due: [DATE] - Owner: [PERSON]\n\n**Next Steps:**\n[NEXT_STEPS]",
                tags: ["meeting", "summary", "template", "productivity"]
            )
        }
    }

    var filteredPrompts: [Prompt] {
        var filtered = prompts

        if !searchText.isEmpty {
            filtered = filtered.filter { prompt in
                prompt.title.localizedCaseInsensitiveContains(searchText) ||
                prompt.content.localizedCaseInsensitiveContains(searchText) ||
                prompt.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.category?.id == selectedCategory.id }
        }

        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }

        return filtered.sorted { $0.updatedAt > $1.updatedAt }
    }

    func loadPrompts() {
        let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PromptEntity.updatedAt, ascending: false)]

        do {
            let entities = try coreDataStack.context.fetch(request)
            prompts = entities.map { Prompt(from: $0) }
        } catch {
            print("Failed to load prompts: \(error)")
        }
    }

    func loadCategories() {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]

        do {
            let entities = try coreDataStack.context.fetch(request)
            categories = entities.map { Category(from: $0) }
        } catch {
            print("Failed to load categories: \(error)")
        }
    }

    func addPrompt(title: String, content: String, tags: [String] = [], category: Category? = nil) {
        let newPrompt = Prompt(title: title, content: content, tags: tags, category: category)
        let entity = newPrompt.toEntity(context: coreDataStack.context)

        if let category = category {
            let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
            categoryRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
            if let categoryEntity = try? coreDataStack.context.fetch(categoryRequest).first {
                entity.category = categoryEntity
            }
        }

        coreDataStack.save()
        loadPrompts()
    }

    func updatePrompt(_ prompt: Prompt, title: String, content: String, tags: [String], category: Category?) {
        let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", prompt.id as CVarArg)

        do {
            if let entity = try coreDataStack.context.fetch(request).first {
                entity.title = title
                entity.content = content
                entity.tags = tags.joined(separator: ",")
                entity.updatedAt = Date()

                if let category = category {
                    let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
                    categoryRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
                    entity.category = try coreDataStack.context.fetch(categoryRequest).first
                } else {
                    entity.category = nil
                }

                coreDataStack.save()
                loadPrompts()
            }
        } catch {
            print("Failed to update prompt: \(error)")
        }
    }

    func deletePrompt(_ prompt: Prompt) {
        let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", prompt.id as CVarArg)

        do {
            if let entity = try coreDataStack.context.fetch(request).first {
                coreDataStack.context.delete(entity)
                coreDataStack.save()
                loadPrompts()
            }
        } catch {
            print("Failed to delete prompt: \(error)")
        }
    }

    func toggleFavorite(_ prompt: Prompt) {
        let request: NSFetchRequest<PromptEntity> = PromptEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", prompt.id as CVarArg)

        do {
            if let entity = try coreDataStack.context.fetch(request).first {
                entity.isFavorite.toggle()
                entity.updatedAt = Date()
                coreDataStack.save()
                loadPrompts()
            }
        } catch {
            print("Failed to toggle favorite: \(error)")
        }
    }

    func addCategory(name: String, color: String? = nil) {
        let newCategory = Category(name: name, color: color)
        _ = newCategory.toEntity(context: coreDataStack.context)
        coreDataStack.save()
        loadCategories()
    }

    func exportPrompts() -> Data? {
        let exportData = prompts.map { prompt in
            [
                "id": prompt.id.uuidString,
                "title": prompt.title,
                "content": prompt.content,
                "tags": prompt.tags,
                "category": prompt.category?.name ?? "",
                "isFavorite": prompt.isFavorite,
                "createdAt": ISO8601DateFormatter().string(from: prompt.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: prompt.updatedAt)
            ]
        }

        return try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }

    func exportPromptsToFile() {
        guard let data = exportPrompts() else { return }

        let savePanel = NSSavePanel()
        savePanel.title = "Export Prompts"
        savePanel.nameFieldStringValue = "prompts_\(DateFormatter.filename.string(from: Date())).json"
        savePanel.allowedContentTypes = [.json]

        if savePanel.runModal() == .OK, let url = savePanel.url {
            do {
                try data.write(to: url)
            } catch {
                print("Failed to export prompts: \(error)")
            }
        }
    }

    func importPromptsFromFile() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import Prompts"
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == .OK, let url = openPanel.url {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]

                json?.forEach { promptData in
                    guard let title = promptData["title"] as? String,
                          let content = promptData["content"] as? String else { return }

                    let tags = promptData["tags"] as? [String] ?? []
                    let categoryName = promptData["category"] as? String
                    let isFavorite = promptData["isFavorite"] as? Bool ?? false

                    let category = categoryName?.isEmpty == false ?
                        categories.first(where: { $0.name == categoryName }) : nil

                    let prompt = Prompt(
                        title: title,
                        content: content,
                        tags: tags,
                        category: category,
                        isFavorite: isFavorite
                    )

                    let entity = prompt.toEntity(context: coreDataStack.context)

                    if let category = category {
                        let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
                        categoryRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
                        if let categoryEntity = try? coreDataStack.context.fetch(categoryRequest).first {
                            entity.category = categoryEntity
                        }
                    }
                }

                coreDataStack.save()
                loadPrompts()
            } catch {
                print("Failed to import prompts: \(error)")
            }
        }
    }
}

extension DateFormatter {
    static let filename: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}