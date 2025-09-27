import CoreData
import Foundation

@MainActor
final class CoreDataStack: ObservableObject, Sendable {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PromptManager")

        // Configure store description for better error handling
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.shouldInferMappingModelAutomatically = true
        storeDescription?.shouldMigrateStoreAutomatically = true

        container.loadPersistentStores { _, error in
            if let error = error {
                // Instead of fatalError, print error and continue
                print("Core Data failed to load: \(error.localizedDescription)")
                print("Creating in-memory store as fallback")

                // Create in-memory store as fallback
                let description = NSPersistentStoreDescription()
                description.type = NSInMemoryStoreType
                container.persistentStoreDescriptions = [description]

                // Try to load again with in-memory store
                container.loadPersistentStores { _, secondError in
                    if let secondError = secondError {
                        print("Even in-memory store failed: \(secondError.localizedDescription)")
                    }
                }
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}