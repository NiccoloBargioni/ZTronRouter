import Foundation

/// Observable storing the state of a Router.
///
/// Use this object to programmatically navigate to a new path, to jump forward or back in the history, to clear the
/// history, or to find out whether the user can go back or forward.
///
/// - Note: This ObservableObject is available inside the hierarchy of a `ZTronRouter`.
///
/// ```swift
/// @ObservableObject var ZTronNavigator:ZTronNavigator
/// ```
public final class ZTronNavigator: ObservableObject {
    public typealias PathComponents = [String]

    @Published private var historyStack: [PathComponents]
    @Published private var forwardStack: [PathComponents] = []
    
    /// Last navigation that occurred.
    @Published public private(set) var lastAction: ZTronNavigationAction?
    
    private let initialPath: PathComponents
    private let rootSymbol: String
    
    /// Initialize a `Navigator` to be fed to `Router` manually.
    ///
    /// Initialize an instance of `Navigator` to keep a reference to outside of the SwiftUI lifecycle.
    ///
    /// - Important: This is considered an advanced usecase for *SwiftUI Router* used for specific design patterns.
    /// It is strongly advised to reference the `Navigator` via the provided Environment Object instead.
    ///
    /// - Parameter initialPath: The initial path the `Navigator` should start at once initialized.
    public init(initialPath: PathComponents = [">"]) {
        assert(initialPath.count > 0, "initial path must not be empty")
        assert(initialPath.count <= 1, "initial path must contain only one symbol")
        assert(initialPath.first != nil, "the first path component can't be an empty string")
        
        self.initialPath = initialPath
        self.historyStack = [initialPath]
        
        self.rootSymbol = initialPath.first!
    }

    // MARK: Getters.
    /// Current navigation path of the Router environment.
    public var path: PathComponents {
        historyStack.last ?? initialPath
    }

    public var canGoBack: Bool {
        historyStack.count > 1
    }
        
    public var canGoForward: Bool {
        !forwardStack.isEmpty
    }

    /// The size of the history stack.
    ///
    /// The amount of times the `Navigator` 'can go back'.
    public var historyStackSize: Int {
        historyStack.count - 1
    }

    /// The size of the forward stack.
    ///
    /// The amount of times the `Navigator` 'can go forward'.
    public var forwardStackSize: Int {
        forwardStack.count
    }
    
    // MARK: Methods.
    /// Navigate to a new location.
    ///
    /// The given path is always relative to the current environment path.
    /// This means you can use `/` to navigate using an absolute path and `..` to go up a directory.
    ///
    /// ```swift
    ///navigator.navigate(["news"]) // Relative.
    ///navigator.navigate([rootSymbol, "settings", "users"]) // Absolute.
    ///navigator.navigate([..]) // Up one, relatively.

    /// ```
    ///
    /// Navigating to the same path as the current path is a noop. If the `DEBUG` flag is enabled, a warning
    /// will be printed to the console.
    ///
    /// - Parameter path: Path of the new location to navigate to.
    /// - Parameter replace: if `true` will replace the last path in the history stack with the new path.
    ///
    /// - Complexity: O(forwardStack.count + (previousPath.count + nextPath.count)), where `previousPath` is the path
    /// before the navigation and `nextPath` is the path to navigate to (absolute or relative). When navigating to an absolute path,
    /// this is reduced to Θ(forwardStack.count + nextPath.count).
    public func navigate(_ path: PathComponents, replace: Bool = false) {
        let path = resolvePaths(self.path, path, root: rootSymbol)
        let previousPath = self.path
        
        guard path != previousPath else {
            #if DEBUG
            print("SwiftUIRouter: Navigating to the same path ignored.")
            #endif
            return
        }
    
        forwardStack.removeAll()

        if replace && !historyStack.isEmpty {
            historyStack[historyStack.endIndex - 1] = path
        }
        else {
            historyStack.append(path)
        }
        
        lastAction = ZTronNavigationAction(
            currentPath: path,
            previousPath: previousPath,
            action: .push
        )
    }

    /// Go back *n* steps in the navigation history.
    ///
    /// `total` will always be clamped and thus prevent from going out of bounds.
    ///
    /// - Parameter total: Total steps to go back.
    /// - Complexity: Θ(total + previousPath.count)
    public func goBack(total: Int = 1) {
        guard canGoBack else {
            return
        }

        let previousPath = path

        let total = min(total, historyStack.count)
        let start = historyStack.count - total
        forwardStack.append(contentsOf: historyStack[start...].reversed())
        historyStack.removeLast(total)
        
        lastAction = ZTronNavigationAction(
            currentPath: path,
            previousPath: previousPath,
            action: .back
        )
    }
    
    /// Go forward *n* steps in the navigation history.
    ///
    /// `total` will always be clamped and thus prevent from going out of bounds.
    ///
    /// - Parameter total: Total steps to go forward.
    ///
    /// - Complexity: Θ(forwardStack.count + previousPath.count)
    public func goForward(total: Int = 1) {
        guard canGoForward else {
            return
        }

        let previousPath = path

        let total = min(total, forwardStack.count)
        let start = forwardStack.count - total
        historyStack.append(contentsOf: forwardStack[start...])
        forwardStack.removeLast(total)
        
        lastAction = ZTronNavigationAction(
            currentPath: path,
            previousPath: previousPath,
            action: .forward
        )
    }
    
    /// Clear the entire navigation history.
    ///
    /// - Complexity: Θ(forwardStack.count)
    public func clear() {
        forwardStack.removeAll()
        historyStack = [path]
        lastAction = nil
    }
    
    public func getRootSymbol() -> String {
        guard let rootSymbol = self.initialPath.first else {
            fatalError("initialPath may not be empty. You should never be able to see this error. Contact github:NickTheFreak97")
        }
        
        return rootSymbol
    }
}

extension ZTronNavigator: Equatable {
    public static func == (lhs: ZTronNavigator, rhs: ZTronNavigator) -> Bool {
        lhs === rhs
    }
}


// MARK: -
/// Information about a navigation that occurred.
public struct ZTronNavigationAction: Equatable {
    public typealias PathComponents = [String]
    /// Directional difference between the current path and the previous path.
    public enum Direction {
        /// The new path is higher up in the hierarchy *or* a completely different path.
        /// Example: `/user/settings` → `/user`. Or `/favorite/music` → `/news/latest`.
        case higher
        /// The new path is deeper in the hierarchy. Example: `/news` → `/news/latest`.
        case deeper
        /// The new path shares the same parent. Example: `/favorite/movies` → `/favorite/music`.
        case sideways
    }
    
    /// The kind of navigation that occurred.
    public enum Action {
        /// Navigated to a new path.
        case push
        /// Navigated back in the stack.
        case back
        /// Navigated forward in the stack.
        case forward
    }
    
    public let action: Action
    public let currentPath: PathComponents
    public let previousPath: PathComponents
    public let direction: Direction
    
    private let rootSymbol: String
    
    /// - Complexity: O(previousPath.count)
    init(currentPath: [String], previousPath: [String], action: Action, rootSymbol: String = ">") {
        self.action = action
        self.currentPath = currentPath
        self.previousPath = previousPath
        self.rootSymbol = rootSymbol
        
        // Check whether the navigation went higher, deeper or sideways.
        if currentPath.count > previousPath.count
            && (currentPath.starts(with: previousPath)
                || (previousPath.count == 1 && previousPath.first! == ">"))
        {
            direction = .deeper
        }
        else {
            if currentPath.count == previousPath.count
                && currentPath.dropLast(1) == previousPath.dropLast(1)
            {
                direction = .sideways
            }
            else {
                direction = .higher
            }
        }
    }
}

extension Array where Element == String {
    /// Checks if this array has its first `contentsOf.count` elements in common with `contentsOf`.
    ///
    /// - Complexity: Ω(1) - if `contentsOf` has more elements than this array, O(contentsOf.count) otherwise.
    /// Overall, worst case is O(contentsOf.count).
    func starts(with contentsOf: [Element]) -> Bool {
        if self.count < contentsOf.count {
            return false
        } else {
            for i in 0..<contentsOf.count {
                if self[i] != contentsOf[i] {
                    return false
                }
            }
            
            return true
        }
    }
}

