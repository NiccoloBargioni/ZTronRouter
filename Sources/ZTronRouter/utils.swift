import Foundation

/// Joins the input paths.
/// - Complexity: O(paths.count) for time and space.
func normalizePath(paths: [String]) -> [String] {
    NSString(string: paths.joined(separator: "/")).standardizingPath.split(separator: "/").map { pathComponent in
        return pathComponent.toString()
    }
}

/// If `rhs` starts with root symbol, `rhs` is returned, otherwise a new path made joining `lhs` and `rhs` is returned
/// - Complexity: O(rhs.count) in the best case scenario, O(lhs.count + rhs.count) in the worst case scenario
func resolvePaths(_ lhs: [String], _ rhs: [String], root: String = ">") -> [String] {
    if rhs.count <= 0 {
        return lhs
    } else {
        let path: [String] = {
            if rhs.first == root {
                return rhs
            } else {
                var path: [String] = Array(lhs)
                path.append(contentsOf: rhs)
                return path
            }

        }()
        
        return NSString(string: path.joined(separator: "/")).standardizingPath.split(separator: "/").map { pathComponent in
            return pathComponent.toString()
        }
    }
}
