import Foundation
import VimTerminalKit

/// This is an example app using VimTerminalKit.
@main
struct FileExplorer {
    static func main() {
        let explorer = Explorer()
        explorer.start()
    }
}

struct FileItem {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: Int64
    let modificationDate: Date

    var displayName: String {
        isDirectory ? "📁 \(name)" : "📄 \(name)"
    }

    var formattedSize: String {
        if isDirectory { return "--" }
        if size < 1024 { return "\(size)B" }
        if size < 1024 * 1024 { return "\(size / 1024)KB" }
        return "\(size / (1024 * 1024))MB"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: modificationDate)
    }
}

final class Explorer {
    private let fileManager = FileManager.default
    private var currentPath: String
    private var items: [FileItem] = []
    private var navigator: VimTerminalKit.Navigator
    private var stateManager: VimTerminalKit.StateManager
    private var isRunning = true
    private var pathHistory: [String] = []

    init() {
        self.currentPath = fileManager.currentDirectoryPath
        // Initialize navigator with single column layout
        self.navigator = .init(itemCount: 1, columnsCount: 1)
        self.stateManager = .init { }
        setupStateManager()
    }

    private func setupStateManager() {
        stateManager = .init { [weak self] in
            self?.clearScreen()
            self?.printInterface()
        }
    }

    private func loadCurrentDirectory() {
        Task { [weak self] in
            guard let self else { return }
            try await self.stateManager.withLoading(message: "Loading directory contents...") {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.currentPath)
                let newItems = try contents.compactMap { name -> FileItem? in
                    let path = (self.currentPath as NSString).appendingPathComponent(name)
                    let attributes = try self.fileManager.attributesOfItem(atPath: path)

                    return FileItem(
                        name: name,
                        path: path,
                        isDirectory: attributes[.type] as? FileAttributeType == .typeDirectory,
                        size: attributes[.size] as? Int64 ?? 0,
                        modificationDate: attributes[.modificationDate] as? Date ?? Date()
                    )
                }
                .sorted { $0.isDirectory && !$1.isDirectory || ($0.isDirectory == $1.isDirectory && $0.name < $1.name) }

                self.items = newItems
                // Update navigator with total items (including parent directory if not at root)
                let totalItems = self.currentPath == "/" ? newItems.count : newItems.count + 1
                self.navigator = .init(itemCount: totalItems, columnsCount: 1)
            }
        }
    }

    func start() {
        VimTerminalKit.setup()
        defer { VimTerminalKit.cleanup() }

        loadCurrentDirectory()

        while isRunning {
            clearScreen()
            printInterface()
            handleInput()
        }
    }

    private func clearScreen() {
        print(VimTerminalKit.Terminal.Control.clearScreen, terminator: "")
    }

    private func printInterface() {
        print("File Explorer")
        print("=============")
        print("Location: \(currentPath)\n")

        if stateManager.isLoading {
            print(stateManager.loadingMessage)
            return
        }

        // Header
        print("Name".padding(toLength: 40, withPad: " ", startingAt: 0) +
              "Size".padding(toLength: 10, withPad: " ", startingAt: 0) +
              "Modified")
        print(String(repeating: "-", count: 70))

        // Parent directory option if not at root
        if currentPath != "/" {
            let parentLine = navigator.selectedIndex == 0 ? "➤ " : "  "
            print(parentLine + "📁 ..".padding(toLength: 38, withPad: " ", startingAt: 0) +
                  "--".padding(toLength: 10, withPad: " ", startingAt: 0) +
                  "--")
        }

        // Items
        for (index, item) in items.enumerated() {
            let adjustedIndex = currentPath == "/" ? index : index + 1
            let prefix = adjustedIndex == navigator.selectedIndex ? "➤ " : "  "
            print(prefix + item.displayName.padding(toLength: 38, withPad: " ", startingAt: 0) +
                  item.formattedSize.padding(toLength: 10, withPad: " ", startingAt: 0) +
                  item.formattedDate)
        }

        print("\nNavigate: ↑↓ or jk | Enter: Open | Backspace: Back | q: Quit")
    }

    private func handleInput() {
        switch VimTerminalKit.InputReader.getInput() {
        case .vim(let direction), .arrow(let direction):
            navigator.navigate(.arrow(direction))

        case .enter:
            handleEnter()

        case .backspace:
            handleBack()

        case .quit:
            isRunning = false

        default:
            break
        }
    }

    private func handleEnter() {
        if navigator.selectedIndex == 0 && currentPath != "/" {
            // Go to parent directory
            pathHistory.append(currentPath)
            currentPath = (currentPath as NSString).deletingLastPathComponent
            loadCurrentDirectory()
            return
        }

        let selectedIndex = currentPath == "/" ? navigator.selectedIndex : navigator.selectedIndex - 1
        guard selectedIndex >= 0 && selectedIndex < items.count else { return }

        let item = items[selectedIndex]
        if item.isDirectory {
            pathHistory.append(currentPath)
            currentPath = item.path
            loadCurrentDirectory()
        }
    }

    private func handleBack() {
        guard let previousPath = pathHistory.popLast() else { return }
        currentPath = previousPath
        loadCurrentDirectory()
    }
}
