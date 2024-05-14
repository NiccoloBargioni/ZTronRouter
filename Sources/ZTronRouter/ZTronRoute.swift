import Foundation

/// Represents a single route in the context of a `ZTronRouter`
///
/// `absolutePath` represents the full path to this route (parent's path joined with this route's relative path to its parent);
/// `output` is the router's output for this route.
public class ZTronRoute<RouteOutput, RouteParameters> {
    private let absolutePath: ZTronNavigator.PathComponents
    private let output: RouteOutput
    private let params: RouteParameters?

    internal init(
        absolutePath: ZTronNavigator.PathComponents,
        output: RouteOutput,
        routeParameters: RouteParameters? = nil
    ) {
        self.absolutePath = absolutePath
        self.output = output
        self.params = routeParameters
    }

    /// Returns the full path from root to this route.
    ///
    /// - Complexity: O(1)
    public func getAbsolutePath() -> ZTronNavigator.PathComponents {
        return self.absolutePath
    }

    public func getOutput() -> RouteOutput {
        return self.output
    }
    
    public func getParams() -> RouteParameters? {
        return self.params
    }
}
