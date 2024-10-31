import Foundation

// Sources/VimTerminalKit/Navigation/Navigator.swift

public extension VimTerminalKit {
    /// Manages navigation state and handles movement through a grid-based interface.
    ///
    /// The Navigator class provides a way to handle selection state in a grid layout,
    /// supporting both single and multi-column arrangements. It automatically handles
    /// wrapping, bounds checking, and cross-column navigation.
    ///
    /// Example usage:
    /// ```swift
    /// let navigator = Navigator(itemCount: 10, columnsCount: 2)
    ///
    /// // Navigate through items
    /// navigator.navigate(.vim(.down))
    /// print("Selected: \(navigator.selectedIndex)")
    /// ```
    final class Navigator {
        /// The currently selected item index.
        public private(set) var selectedIndex: Int

        /// The currently selected column (0-based).
        public private(set) var selectedColumn: Int

        /// The total number of items that can be navigated.
        private let itemCount: Int

        /// The number of columns to arrange items in.
        private let columnsCount: Int

        /// Creates a new navigator instance.
        ///
        /// - Parameters:
        ///   - itemCount: The total number of items that can be selected
        ///   - columnsCount: The number of columns to arrange items in (default: 2)
        ///   - initialIndex: The starting selected index (default: 0)
        ///   - initialColumn: The starting selected column (default: 0)
        public init(itemCount: Int, columnsCount: Int = 2, initialIndex: Int = 0, initialColumn: Int = 0) {
            self.itemCount = itemCount
            self.columnsCount = columnsCount
            self.selectedIndex = initialIndex
            self.selectedColumn = initialColumn
        }

        /// Processes a navigation input and updates the selection state.
        ///
        /// - Parameter input: The input type representing the desired navigation direction
        public func navigate(_ input: InputType) {
            guard itemCount > 0 else { return }

            let midpoint = (itemCount + columnsCount - 1) / columnsCount

            switch input {
            case .vim(.up), .arrow(.up):
                navigateUp(midpoint: midpoint)
            case .vim(.down), .arrow(.down):
                navigateDown(midpoint: midpoint)
            case .vim(.right), .arrow(.right):
                navigateRight(midpoint: midpoint)
            case .vim(.left), .arrow(.left):
                navigateLeft(midpoint: midpoint)
            default:
                break
            }
        }

        /// Handles upward navigation with wrapping.
        private func navigateUp(midpoint: Int) {
            let offset = selectedColumn * midpoint
            let maxIndex = selectedColumn == 0 ? midpoint : itemCount
            selectedIndex = ((selectedIndex - 1 - offset + midpoint) % midpoint) + offset
            if selectedIndex >= maxIndex {
                selectedIndex = maxIndex - 1
            }
        }

        /// Handles downward navigation with wrapping.
        private func navigateDown(midpoint: Int) {
            let offset = selectedColumn * midpoint
            let maxIndex = selectedColumn == 0 ? midpoint : itemCount
            selectedIndex = ((selectedIndex + 1 - offset) % midpoint) + offset
            if selectedIndex >= maxIndex {
                selectedIndex = offset
            }
        }

        /// Handles rightward navigation between columns.
        private func navigateRight(midpoint: Int) {
            if selectedColumn == 0 {
                selectedColumn = 1
                let newIndex = selectedIndex + midpoint
                if newIndex >= itemCount {
                    selectedColumn = 0
                } else {
                    selectedIndex = newIndex
                }
            }
        }

        /// Handles leftward navigation between columns.
        private func navigateLeft(midpoint: Int) {
            if selectedColumn == 1 {
                selectedColumn = 0
                selectedIndex -= midpoint
            }
        }
    }
}

