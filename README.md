# PromptManager

A native macOS app for storing and managing AI prompts, built with SwiftUI and Core Data.

## Features

- **Prompt Management**: Create, edit, delete, and organize your AI prompts
- **Categories & Tags**: Organize prompts with categories and tags for easy retrieval
- **Search & Filter**: Full-text search across prompts with filtering by categories and favorites
- **Import/Export**: Backup and share your prompts via JSON export/import
- **Keyboard Shortcuts**: Efficient navigation and actions via keyboard shortcuts
- **Native macOS Design**: Follows macOS design guidelines with sidebar navigation

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building from source)

## Building and Running

1. **Open in Xcode**:
   ```bash
   open PromptManager.xcodeproj
   ```

2. **Build and Run**:
   - Select the PromptManager scheme
   - Click the Run button (⌘R) or go to Product → Run

## Usage

### Keyboard Shortcuts

- **⌘N**: Create new prompt
- **⌘⇧E**: Export all prompts to JSON
- **⌘⇧I**: Import prompts from JSON
- **Space**: Toggle favorite for selected prompt
- **Delete**: Delete selected prompt

### Getting Started

The app comes with sample prompts to help you get started:
- Creative Writing Starter (Writing category)
- Code Review Assistant (Coding category)
- Data Analysis Helper (Analysis category)
- Meeting Summary Template (General)

### Creating Prompts

1. Click the "+" button in the sidebar or press ⌘N
2. Fill in the title and content
3. Add tags separated by commas (optional)
4. Select a category (optional)
5. Click "Create" to save

### Organizing with Categories

1. In the sidebar, click the "+" next to "Category:"
2. Enter a category name
3. Assign prompts to categories when creating or editing

### Search and Filter

- Use the search bar to find prompts by title, content, or tags
- Toggle "Favorites Only" to see starred prompts
- Filter by category using the dropdown menu

### Export/Import

- **Export**: File → Export All Prompts... (⌘⇧E)
- **Import**: File → Import Prompts... (⌘⇧I)

Data is stored locally using Core Data for privacy and offline access.

## Project Structure

```
PromptManager/
├── PromptManager.xcodeproj/       # Xcode project file
└── PromptManager/
    ├── App/                       # Main app and content view
    │   ├── PromptManagerApp.swift
    │   └── ContentView.swift
    ├── Models/                    # Data models and Core Data stack
    │   ├── CoreDataStack.swift
    │   └── Prompt.swift
    ├── Views/                     # SwiftUI views
    │   ├── PromptListView.swift
    │   ├── PromptDetailView.swift
    │   └── PromptEditView.swift
    ├── ViewModels/                # View models for data management
    │   └── PromptViewModel.swift
    └── Resources/                 # Core Data model and assets
        └── PromptManager.xcdatamodeld/
```

## Contributing

This is a sample project. Feel free to fork and modify for your own use.

## License

This project is provided as-is for educational and personal use.