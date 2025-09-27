import CoreData
import Foundation

@MainActor
final class SafeCoreDataStack: ObservableObject {
    static let shared = SafeCoreDataStack()

    private var _persistentContainer: NSPersistentContainer?

    var persistentContainer: NSPersistentContainer {
        if let container = _persistentContainer {
            return container
        }

        let container = NSPersistentContainer(name: "PromptManager")

        // Use in-memory store to avoid file system issues
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        let group = DispatchGroup()
        group.enter()

        container.loadPersistentStores { _, error in
            loadError = error
            group.leave()
        }

        group.wait()

        if let error = loadError {
            print("Core Data load error: \(error)")
            // Create a fallback container
            let fallbackContainer = NSPersistentContainer(name: "PromptManager")
            let fallbackDescription = NSPersistentStoreDescription()
            fallbackDescription.type = NSInMemoryStoreType
            fallbackContainer.persistentStoreDescriptions = [fallbackDescription]

            fallbackContainer.loadPersistentStores { _, _ in
                // Ignore errors in fallback
            }

            self._persistentContainer = fallbackContainer
            return fallbackContainer
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        self._persistentContainer = container
        return container
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}