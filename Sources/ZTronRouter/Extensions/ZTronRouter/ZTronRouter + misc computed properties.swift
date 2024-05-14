import Foundation
import RoutingKit

extension ZTronRouter {
    
    /// The output of the router at the current path.
    ///
    /// - Complexity: O(currentPath.count) for recomputing
    public var output: RouterOutput? {
        var parameters = Parameters()
        return self.trie.route(path: self.path, parameters: &parameters)
    }
}

