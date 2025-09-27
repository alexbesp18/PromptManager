import Foundation
import CoreData

// MARK: - Core Data Entity Definitions

@objc(PromptEntity)
public class PromptEntity: NSManagedObject {
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var tags: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var category: CategoryEntity?
}

extension PromptEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PromptEntity> {
        return NSFetchRequest<PromptEntity>(entityName: "PromptEntity")
    }
}

@objc(CategoryEntity)
public class CategoryEntity: NSManagedObject {
    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var prompts: NSSet?
}

extension CategoryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @objc(addPromptsObject:)
    @NSManaged public func addToPrompts(_ value: PromptEntity)

    @objc(removePromptsObject:)
    @NSManaged public func removeFromPrompts(_ value: PromptEntity)

    @objc(addPrompts:)
    @NSManaged public func addToPrompts(_ values: NSSet)

    @objc(removePrompts:)
    @NSManaged public func removeFromPrompts(_ values: NSSet)
}

struct Prompt: Identifiable, Hashable {
    let id: UUID
    let title: String
    let content: String
    let tags: [String]
    let category: Category?
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date

    init(id: UUID = UUID(), title: String, content: String, tags: [String] = [], category: Category? = nil, isFavorite: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct Category: Identifiable, Hashable {
    let id: UUID
    let name: String
    let color: String?
    let createdAt: Date

    init(id: UUID = UUID(), name: String, color: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
}

extension Prompt {
    init(from entity: PromptEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.content = entity.content ?? ""
        self.tags = entity.tags?.components(separatedBy: ",").filter { !$0.isEmpty } ?? []
        self.category = entity.category.map { Category(from: $0) }
        self.isFavorite = entity.isFavorite
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
    }

    func toEntity(context: NSManagedObjectContext) -> PromptEntity {
        let entity = PromptEntity(context: context)
        entity.id = self.id
        entity.title = self.title
        entity.content = self.content
        entity.tags = self.tags.joined(separator: ",")
        entity.isFavorite = self.isFavorite
        entity.createdAt = self.createdAt
        entity.updatedAt = self.updatedAt
        return entity
    }
}

extension Category {
    init(from entity: CategoryEntity) {
        self.init(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            color: entity.color,
            createdAt: entity.createdAt ?? Date()
        )
    }

    func toEntity(context: NSManagedObjectContext) -> CategoryEntity {
        let entity = CategoryEntity(context: context)
        entity.id = self.id
        entity.name = self.name
        entity.color = self.color
        entity.createdAt = self.createdAt
        return entity
    }
}