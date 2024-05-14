import Foundation

extension ZTronRouter {
    public var path: ZTronNavigator.PathComponents {
        return self.navigator.path
    }

    public var canGoBack: Bool {
        return self.navigator.canGoBack
    }

    public var canGoForward: Bool {
        return self.navigator.canGoForward
    }

    public var historyStackSize: Int {
        return self.navigator.historyStackSize
    }

    public var forwardStackSize: Int {
        self.navigator.forwardStackSize
    }

    public var lastAction: ZTronNavigationAction? {
        return self.navigator.lastAction
    }

    /// Navigate to a new location.
    ///
    /// The given path is always relative to the current environment path.
    /// This means you can use `initialPath.first` (alias `rootSymbol`) to navigate using an absolute path and `..` to go up a directory.
    ///
    /// ```swift
    ///ztronRouter.navigate(["news"]) // Relative.
    ///ztronRouter.navigate([rootSymbol, "settings", "users"]) // Absolute.
    ///ztronRouter.navigate([..]) // Up one, relatively.
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
    public func navigate(_ path: ZTronNavigator.PathComponents, replace: Bool = false) {
        self.navigator.navigate(path, replace: replace)
    }

    /// Go back *n* steps in the navigation history.
    ///
    /// `total` will always be clamped and thus prevent from going out of bounds.
    ///
    /// - Parameter total: Total steps to go back.
    /// - Complexity: Θ(total + previousPath.count)
    public func goBack(total: Int = 1) {
        self.navigator.goBack(total: total)
    }

    /// Go forward *n* steps in the navigation history.
    ///
    /// `total` will always be clamped and thus prevent from going out of bounds.
    ///
    /// - Parameter total: Total steps to go forward.
    ///
    /// - Complexity: Θ(forwardStack.count + previousPath.count)
    public func goForward(total: Int = 1) {
        self.navigator.goForward(total: total)
    }
    
    /// Clear the entire navigation history. This doesn't destroy the current path, which will remain the only element in
    /// the history, and preserves the initial path.
    ///
    /// - Complexity: Θ(forwardStack.count)
    public func clear() {
        self.navigator.clear()
    }
    
    /// Returns the root symbol of self.
    ///
    /// - Complexity: Θ(1)
    public func getRootSymbol() -> ZTronNavigator.PathComponents.Element {
        return self.navigator.getRootSymbol()
    }
}
