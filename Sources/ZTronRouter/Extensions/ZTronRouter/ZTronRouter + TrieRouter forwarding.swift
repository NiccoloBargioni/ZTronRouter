import Foundation
import RoutingKit

extension ZTronRouter {
    public typealias NodeWithAbsolutePath = TrieRouter<RouterOutput>.NodeWithAbsolutePath
    
    /// - Returns: A topological sort of all the routes with an associated (i.e. non nil) output in the router. It requires the paths graph to be a DAG, otherwise
    /// it returns nil.
    ///
    /// - Complexity: **Time**: O(V) where V is the number of distinct path components in the router
    /// **Space:** O(V) to store the topologically sorted vertices of the graph.
    public func topologicalSort() -> [ZTronRoute<RouterOutput, RouteParameter>]? {
        return self.trie.map { absolutePath, output in
            return ZTronRoute<RouterOutput, RouteParameter>(
                absolutePath: absolutePath,
                output: output,
                routeParameters: self.params[absolutePath]
            )
        }
    }
    
    /// Iterates through all the neighbours of the specified endpoint, if it exists. Nothing happens otherwise
    ///
    /// - Parameter endpoint: The path to find neighbours for.
    ///
    /// - Complexity: **Time:** Overall: O(currentPath.count + endpoint.count). **Space:** O(b) to store all the neighbours of the specified path.
    public func forEachNeighbour(
        of endpoint: ZTronNavigator.PathComponents,
        _ body: @escaping (_ absolutePath: ZTronNavigator.PathComponents, _ output: RouterOutput) throws -> Void
    ) rethrows -> Void {
        let resolvedPath = resolvePaths(self.path, endpoint)

        try self.trie.forEachNeighbour(parentPath: resolvedPath) { absolutePath, output in
            try body(absolutePath, output)
        }
    }
    
    /// Transforms all the neighbours of the specified endpoint, if it exists. Otherwise `nil` is returned.
    ///
    /// - Parameter endpoint: The path to find neighbours for.
    /// - Note: If `resolvePath(currentPath, endpoint)` is a valid registered path of constants, the return value of this function is safe to unwrap.
    ///
    /// - Complexity: **Time:** Overall: O(currentPath.count + endpoint.count). **Space:** O(b) to store all the neighbours of the specified path.
    public func mapNeighbours<T>(
        for endpoint: ZTronNavigator.PathComponents,
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> T
    ) rethrows -> [T]? {
        let resolvedPath = resolvePaths(self.path, endpoint)

        return try self.trie.mapNeighbours(parentPath: resolvedPath, transform)
    }
    
    /// Transforms all the neighbours of the specified endpoint, if it exists. Otherwise `nil` is returned.
    ///
    /// - Parameter endpoint: The path to find neighbours for.
    /// - Note: If `resolvePath(currentPath, endpoint)` is a valid registered path of constants, the return value of this function is safe to unwrap.
    ///
    /// - Complexity: **Time:** Overall: O(currentPath.count + endpoint.count). **Space:** O(b) to store all the neighbours of the specified path.
    public func compactMapNeighbours<T>(
        for endpoint: ZTronNavigator.PathComponents,
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> T?
    ) rethrows -> [T]? {
        let resolvedPath = resolvePaths(self.path, endpoint)

        return try self.trie.compactMapNeighbours(parentPath: resolvedPath, transform)
    }
    
    /// Iterates through all the neighbours of the specified endpoint, including neighbours with no associated output , if it exists. Nothing happens otherwise
    ///
    /// - Parameter endpoint: The path to find neighbours for.
    ///
    /// - Complexity: **Time:** Overall: O(currentPath.count + endpoint.count). **Space:** O(b) to store all the neighbours of the specified path.
    public func forEachNeighbouringSlice(
        of endpoint: ZTronNavigator.PathComponents,
        _ body: @escaping (_ absolutePath: ZTronNavigator.PathComponents, _ output: RouterOutput?) throws -> Void
    ) rethrows -> Void {
        let resolvedPath = resolvePaths(self.path, endpoint)

        try self.trie.forEachNeighbouringSlice(parentPath: resolvedPath, body)
    }
    
    /// Transforms all the neighbours of the specified endpoint, including neighbours with no associated output , if it exists. Nothing happens otherwise
    ///
    /// - Parameter endpoint: The path to find neighbours for.
    ///
    /// - Complexity: **Time:** Overall: O(currentPath.count + endpoint.count). **Space:** O(b) to store all the neighbours of the specified path.
    public func mapNeighbouringSlices<T>(
        for endpoint: ZTronNavigator.PathComponents,
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput?) throws -> T
    ) rethrows -> [T]? {
        let resolvedPath = resolvePaths(self.path, endpoint)

        return try self.trie.mapNeighbouringSlices(parentPath: resolvedPath, transform)
    }
    
    /// Transforms all the neighbours of the specified endpoint, including neighbours with no associated output , if it exists. Nothing happens otherwise
    ///
    /// - Parameter endpoint: The path to find neighbours for.
    ///
    /// - Complexity: **Time:** Overall: O(currentPath.count + endpoint.count). **Space:** O(b) to store all the neighbours of the specified path.
    public func compactMapNeighbouringSlices<T>(
        for endpoint: ZTronNavigator.PathComponents,
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput?) throws -> T?
    ) rethrows -> [T]? {
        let resolvedPath = resolvePaths(self.path, endpoint)

        return try self.trie.compactMapNeighbouringSlices(parentPath: resolvedPath, transform)
    }
    
    /// - Returns: The registered output of the graph for the specified path, if it exists; nil otherwise.
    /// - Parameter at: The path to peek.
    ///
    /// - Complexity: **Time:** O(currentPath.count + at.count). **Space:** O(1).
    public func peek(at path: ZTronNavigator.PathComponents) -> RouterOutput? {
        let peekPath = resolvePaths(self.navigator.path, path)
        
        var params = Parameters()
        return self.trie.route(path: peekPath, parameters: &params)
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) via BFS.
    ///
    /// - Parameter visitOrder: A function that sorts the neighbours of every route before visiting them.
    /// - Parameter shouldVisitNeighbours: A function that gatekeeps the visit of the subtree of a route.
    ///
    /// - Complexity: **Time:** O(V·`visitOrder.cost(b)`) where V is the number of distinct path components registered in the router and b
    /// is the maximum number of neighbours of a path component in the router. **Memory:** O(V) for BFS search queue.
    public func forEachBFS(
        from subtreeRoot: ZTronNavigator.PathComponents = [],
        visitOrder: @escaping ([NodeWithAbsolutePath]) -> [NodeWithAbsolutePath] = { $0 },
        shouldVisitNeighbours: @escaping (NodeWithAbsolutePath) -> Bool = { _ in return true },
        _ body: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> Void
    ) rethrows {
        let resolvedPath = resolvePaths(self.path, subtreeRoot)
        
        try self.trie.forEachBFS(
            rootPath: resolvedPath,
            visitOrder: visitOrder,
            shouldVisitNeighbours: shouldVisitNeighbours,
            body
        )
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) via BFS.
    /// This is a sintactic candy for a BFS followed by another loop on the results array.
    ///
    /// If performance is required and the structure is large, prefer the version whose `body` takes two input parameters and
    /// fetch the parameters as follows:
    ///
    ///  ```swift
    /// theRouter.forEachBFS { path, output in
    ///     let paramForPath = theRouter.getParameter(for: path)
    /// }
    /// ```
    ///
    /// - Parameter visitOrder: A function that sorts the neighbours of every route before visiting them.
    /// - Parameter shouldVisitNeighbours: A function that gatekeeps the visit of the subtree of a route.
    ///
    /// - Complexity: **Time:** O(V·`visitOrder.cost(b)`) where V is the number of distinct path components registered in the router and b
    /// is the maximum number of neighbours of a path component in the router. **Memory:** O(V) for BFS search queue.
    public func forEachBFS(
        from subtreeRoot: ZTronNavigator.PathComponents = [],
        visitOrder: @escaping ([NodeWithAbsolutePath]) -> [NodeWithAbsolutePath] = { $0 },
        shouldVisitNeighbours: @escaping (NodeWithAbsolutePath) -> Bool = { _ in return true },
        _ body: @escaping (_ absolutePath: [String], _ output: RouterOutput, _ params: RouteParameter?) throws -> Void
    ) rethrows {
        let resolvedPath = resolvePaths(self.path, subtreeRoot)

        let bfsOrderedResults = self.trie.mapBFS(
            rootPath: resolvedPath,
            visitOrder: visitOrder,
            shouldVisitNeighbours: shouldVisitNeighbours
        ) { absolutePath, output in
            return (absolutePath, output)
        }
        
        try bfsOrderedResults.forEach { pathOutputPair in
            try body(pathOutputPair.0, pathOutputPair.1, self.params[pathOutputPair.0])
        }
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a topologically sorted order.
    ///
    /// - Complexity: O(V) where V is the number of distinct path components registered in the router; both for time and memory
    public func forEach(_ body: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> Void) rethrows {
        try self.trie.forEach(body)
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a topologically sorted order.
    ///
    /// This is a sintactic candy for a topologically ordered traversal followed by another loop on the results array.
    ///
    /// If performance is required and the structure is large, prefer the version whose `body` takes two input parameters and
    /// fetch the parameters as follows:
    ///
    ///  ```swift
    /// theRouter.forEach { path, output in
    ///     let paramForPath = theRouter.getParameter(for: path)
    /// }
    /// ```
    ///
    /// - Complexity: O(V) where V is the number of distinct path components registered in the router; both for time and memory
    public func forEach(
        _ body: @escaping (
            _ absolutePath: [String],
            _ output: RouterOutput,
            _ parameter: RouteParameter?
        ) throws -> Void) rethrows {
            
            let topologicallyOrderedRoutes = self.map { absolutePath, output in
                return (absolutePath, output)
            }
            
            try topologicallyOrderedRoutes.forEach { pathOutputPair in
                try body(pathOutputPair.0, pathOutputPair.1, self.params[pathOutputPair.0])
            }
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a BFS order, and creates a new array applying the
    /// specified transformation to each route with an associated output.
    ///
    /// - Parameter visitOrder: A function that sorts the neighbours of every route before visiting them.
    /// - Parameter shouldVisitNeighbours: A function that gatekeeps the visit of the subtree of a route.
    ///
    /// - Complexity: **Time:** O(V·`visitOrder.cost(b)`) where V is the number of distinct path components registered in the router and b
    /// is the maximum number of neighbours of a path component in the router. **Memory:** O(V) for BFS search queue.
    public func mapBFS<T>(
        from subtreeRoot: ZTronNavigator.PathComponents = [],
        visitOrder: @escaping ([NodeWithAbsolutePath]) -> [NodeWithAbsolutePath] = { $0 },
        shouldVisitNeighbours: @escaping (NodeWithAbsolutePath) -> Bool = { _ in return true },
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> T
    ) rethrows -> [T] {
        let resolvedPath = resolvePaths(self.path, subtreeRoot)
        
        return try self.trie.mapBFS(
            rootPath: resolvedPath,
            visitOrder: visitOrder,
            shouldVisitNeighbours: shouldVisitNeighbours,
            transform
        )
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a BFS order, and creates a new array applying the
    /// specified transformation to each route with an associated output.
    ///
    /// This is a sintactic candy for a BFS traversal followed by another loop on the results array.
    ///
    /// If performance is required and the structure is large, prefer the version whose `body` takes two input parameters and
    /// fetch the parameters as follows:
    ///
    ///  ```swift
    /// theRouter.mapBFS { path, output in
    ///     let paramForPath = theRouter.getParameter(for: path)
    ///     // Process path, output and parameters
    ///     return theProcessedValue
    /// }
    /// ```
    ///
    /// - Parameter visitOrder: A function that sorts the neighbours of every route before visiting them.
    /// - Parameter shouldVisitNeighbours: A function that gatekeeps the visit of the subtree of a route.
    ///
    /// - Complexity: **Time:** O(V·`visitOrder.cost(b)`) where V is the number of distinct path components registered in the router and b
    /// is the maximum number of neighbours of a path component in the router. **Memory:** O(V) for BFS search queue.
    public func mapBFS<T>(
        from subtreeRoot: ZTronNavigator.PathComponents = [],
        visitOrder: @escaping ([NodeWithAbsolutePath]) -> [NodeWithAbsolutePath] = { $0 },
        shouldVisitNeighbours: @escaping (NodeWithAbsolutePath) -> Bool = { _ in return true },
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput, _ parameter: RouteParameter?) throws -> T
    ) rethrows -> [T] {
        let resolvedPath = resolvePaths(self.path, subtreeRoot)

        let BFSTraversalResults = self.trie.mapBFS(
            rootPath: resolvedPath,
            visitOrder: visitOrder,
            shouldVisitNeighbours: shouldVisitNeighbours
        ) { absolutePath, output in
            return (absolutePath, output)
        }
        
        return try BFSTraversalResults.map { pathOutputPair in
            return try transform(pathOutputPair.0, pathOutputPair.1, self.params[pathOutputPair.0])
        }
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a BFS order, and creates a new array applying the
    /// specified transformation to each route with an associated output. Routes that are transformed to `nil` aren't included in the output array.
    ///
    /// - Parameter visitOrder: A function that sorts the neighbours of every route before visiting them.
    /// - Parameter shouldVisitNeighbours: A function that gatekeeps the visit of the subtree of a route.
    ///
    /// - Complexity: **Time:** O(V·`visitOrder.cost(b)`) where V is the number of distinct path components registered in the router and b
    /// is the maximum number of neighbours of a path component in the router;
    /// **Memory:** O(V) for BFS search queue.
    public func compactMapBFS<T>(
        from subtreeRoot: ZTronNavigator.PathComponents = [],
        visitOrder: @escaping ([NodeWithAbsolutePath]) -> [NodeWithAbsolutePath] = { $0 },
        shouldVisitNeighbours: @escaping (NodeWithAbsolutePath) -> Bool = { _ in return true },
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> T?
    ) rethrows -> [T] {
        let resolvedPath = resolvePaths(self.path, subtreeRoot)

        return try self.trie.compactMapBFS(
            rootPath: resolvedPath,
            visitOrder: visitOrder,
            shouldVisitNeighbours: shouldVisitNeighbours,
            transform
        )
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a BFS order, and creates a new array applying the
    /// specified transformation to each route with an associated output. Routes that are transformed to `nil` aren't included in the output array.
    ///
    /// This is a sintactic candy for a BFS traversal followed by another loop on the results array.
    ///
    /// If performance is required and the structure is large, prefer the version whose `body` takes two input parameters and
    /// fetch the parameters as follows:
    ///
    ///  ```swift
    /// theRouter.compactMapBFS { path, output in
    ///     let paramForPath = theRouter.getParameter(for: path)
    ///     // Process path, output and parameters
    ///     return theProcessedValue
    /// }
    /// ```
    ///
    /// - Parameter visitOrder: A function that sorts the neighbours of every route before visiting them.
    /// - Parameter shouldVisitNeighbours: A function that gatekeeps the visit of the subtree of a route.
    ///
    /// - Complexity: **Time:** O(V·`visitOrder.cost(b)`) where V is the number of distinct path components registered in the router and b
    /// is the maximum number of neighbours of a path component in the router;
    /// **Memory:** O(V) for BFS search queue.
    public func compactMapBFS<T>(
        from subtreeRoot: ZTronNavigator.PathComponents = [],
        visitOrder: @escaping ([NodeWithAbsolutePath]) -> [NodeWithAbsolutePath] = { $0 },
        shouldVisitNeighbours: @escaping (NodeWithAbsolutePath) -> Bool = { _ in return true },
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput, _ parameter: RouteParameter?) throws -> T?
    ) rethrows -> [T] {
        let resolvedPath = resolvePaths(self.path, subtreeRoot)

        let BFSTraversalResults = self.trie.mapBFS(
            rootPath: resolvedPath,
            visitOrder: visitOrder,
            shouldVisitNeighbours: shouldVisitNeighbours
        ) { absolutePath, output in
            return (absolutePath, output)
        }
        
        return try BFSTraversalResults.compactMap { pathOutputPair in
            return try transform(pathOutputPair.0, pathOutputPair.1, self.params[pathOutputPair.0])
        }
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a topological order, and creates a new array applying the
    /// specified transformation to each route with an associated output.
    ///
    /// - Complexity: O(V) where V is the number of distinct path components registered in the router; both for time and memory
    public func map<T>(_ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> T) rethrows -> [T] {
        return try self.trie.map(transform)
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a topological order, and creates a new array applying the
    /// specified transformation to each route with an associated output.
    ///
    /// This is a sintactic candy for a topologically ordered traversal followed by another loop on the results array.
    ///
    /// If performance is required and the structure is large, prefer the version whose `body` takes two input parameters and
    /// fetch the parameters as follows:
    ///
    ///  ```swift
    /// theRouter.map { path, output in
    ///     let paramForPath = theRouter.getParameter(for: path)
    ///     // Process path, output and parameters
    ///     return theProcessedValue
    /// }
    /// ```
    ///
    /// - Complexity: O(V) where V is the number of distinct path components registered in the router; both for time and memory
    public func map<T>(
        _ transform: @escaping (
            _ absolutePath: [String],
            _ output: RouterOutput,
            _ parameter: RouteParameter?
        ) throws -> T
    ) rethrows -> [T] {
        let mappedRoutes = self.trie.map { absolutePath, output in
            return (absolutePath, output)
        }
        
        return try mappedRoutes.map { pathOutputPair in
            return try transform(pathOutputPair.0, pathOutputPair.1, self.params[pathOutputPair.0])
        }
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a topological order, and creates a new array applying the
    /// specified transformation to each route with an associated output. Routes that are transformed to `nil` aren't included in the output array.
    ///
    /// - Complexity: O(V) where V is the number of distinct path components registered in the router; both for time and memory
    private func compactMap<T>(
        _ transform: @escaping (_ absolutePath: [String], _ output: RouterOutput) throws -> T?
    ) rethrows -> [T] {
        return try self.trie.compactMapBFS(transform)
    }
    
    /// Traverses all the constant routes (no parameters, anything, catchalls) following a topological order, and creates a new array applying the
    /// specified transformation to each route with an associated output. Routes that are transformed to `nil` aren't included in the output array.
    ///
    /// This is a sintactic candy for a topologically ordered traversal followed by another loop on the results array.
    ///
    /// If performance is required and the structure is large, prefer the version whose `body` takes two input parameters and
    /// fetch the parameters as follows:
    ///
    ///  ```swift
    /// theRouter.compactMapBFS { path, output in
    ///     let paramForPath = theRouter.getParameter(for: path)
    ///     // Process path, output and parameters
    ///     return theProcessedValue
    /// }
    /// ```
    ///
    /// - Complexity: O(V) where V is the number of distinct path components registered in the router; both for time and memory
    private func compactMap<T>(
        _ transform: @escaping (
            _ absolutePath: [String],
            _ output: RouterOutput,
            _ parameter: RouteParameter?
        ) throws -> T?) rethrows -> [T] {
            let topologicalTraversalResults = self.trie.map { absolutePath, output in
                return (absolutePath, output)
            }
            
            return try topologicalTraversalResults.compactMap { pathOutputPair in
                return try transform(pathOutputPair.0, pathOutputPair.1, self.params[pathOutputPair.0])
            }
    }
    
    /// Creates a new ZTronRouter starting from two distinct routers, if possible.
    ///
    /// - Parameter to: the router to zip this router to.
    /// - Parameter transformInfo: Maps the router informations of the two routers to the informations of the zipped one.
    /// - Parameter transformOutput: For each common absolute path with a registered output, it maps the output of the two routers to the output of the result.
    /// - Parameter transformParameters: For each route with an associated parameter in at least one of the two zipped router,
    /// it maps the parameters of the two routers to the parameter of the result. Return nil to ignore the pair.
    ///
    /// In order to be able to create a new router, the following conditions are necessary:
    /// - The two input routers share the same set of routes.
    /// - If the two routers have at least one registered path, the two routers must share the same root symbol.
    ///
    /// - Complexity: **Time:** O(V⋅b⋅log(b)) to zip the tries, and additional O(V) to map parameters. **Memory:** O(V).
    public func zip<RHSInfo, RHSOutput, RHSParameter, ResultInfo, ResultParameter, ResultOutput>(
        to otherRouter: ZTronRouter<RHSInfo, RHSOutput, RHSParameter>,
        transformInfo: @escaping (
            _ lhsInfo: RouterInfo,
            _ rhsInfo: RHSInfo
        ) throws -> ResultInfo = { (lhsInfo: RouterInfo, rhsInfo: RHSInfo) in
            return (lhsInfo, rhsInfo)
        },
        transformOutput: @escaping (
            _ absolutePath: [String],
            _ lhsOutput: RouterOutput,
            _ rhsOutput: RHSOutput
        ) throws -> ResultOutput = { (absolutePath: [String], lhsOutput: RouterOutput, rhsOutput: RHSOutput) in
            return (lhsOutput, rhsOutput)
        },
        transformParameters: @escaping (
            _ absolutePath: [String],
            _ lhsParam: RouteParameter?,
            _ rhsParam: RHSParameter?
        ) throws -> ResultParameter? = { (absolutePath: [String], lhsParam: RouteParameter?, rhsParam: RHSParameter?) in
            return (lhsParam, rhsParam)
        }
    ) rethrows -> ZTronRouter<ResultInfo, ResultOutput, ResultParameter>? {
        
        guard let zippedTrie = try self.trie.zip(
            to: otherRouter.trie,
            transformOutput
        ) else {
            return nil
        }
        
        if self.registeredRoutesCount != otherRouter.registeredRoutesCount ||
            self.maxDepth != otherRouter.maxDepth {
            return nil
        } else {
            let newRouterInfo = try transformInfo(self.routerInfo, otherRouter.routerInfo)
            
            guard let newRouter = ZTronRouter<ResultInfo, ResultOutput, ResultParameter>(
                routerInfo: newRouterInfo,
                withTrie: zippedTrie
            ) else {
                return nil
            }
            
            try self.forEach { absolutePath, output in
                let myParamForCurrentRoute = self.getParameter(for: absolutePath)
                let otherParamForCurrentRoute = otherRouter.getParameter(for: absolutePath)
                
                if myParamForCurrentRoute != nil || otherParamForCurrentRoute != nil {
                    if let newParam = try transformParameters(absolutePath, myParamForCurrentRoute, otherParamForCurrentRoute) {
                        newRouter.params[absolutePath] = newParam
                    }
                }
            }
            
            return newRouter
        }
    }
    
    /// Registers a new route to the router and creates the meta informations to track it.
    ///
    /// - Parameter at: The path where to register the specified path.
    /// - Parameter output: The output to associate to the specified path.
    ///
    /// If path doesn't include `initialPath.first` as its first element, it is considered as a path relative to `currentPath`.
    ///
    /// Let `destinationPath` be the resolved path between the current path and `at`.
    /// - Complexity: **Time:**  O(currentPath.count + destinationPath.count)
    /// **Space:** Θ(1)
    public func register(
        _ output: RouterOutput,
        at: ZTronNavigator.PathComponents,
        withParameter: RouteParameter? = nil
    ) {
        
        // TODO: WHAT IF AN OUTPUT IS ALREADY REGISTERED AT THIS PATH?
        let destinationPath = resolvePaths(self.navigator.path, at)
        
        var parameters = Parameters()
        guard self.trie.route(path: at, parameters: &parameters) == nil else { return }
        
        self.trie.register(output, at: destinationPath.map { component in
            return PathComponent.constant(component)
        })
        
        self.registeredRoutesCount += 1

        if destinationPath.count - 1 > self.maxDepth {
            self.maxDepth = destinationPath.count - 1
        }
        
        if let withParams = withParameter {
            self.params[destinationPath] = withParams
        }
    }
    
    /// Tests whether or not this router contains a path component `named` in the subtree rooted in `rootPath`.
    ///
    /// - Returns: `true` if a slice with the specified name is found in the subtree of `rootPath`, `false` otherwise.
    ///
    /// - Complexity: Time: O(V + (currentPath.count + rootPath.count)) where V is the number of path components in the subtree rooted in rootPath. Memory: O(1)
    public func hasSlice(named: String, rootPath: ZTronNavigator.PathComponents = []) -> Bool {
        let resolvedPath = resolvePaths(self.path, rootPath)
        return self.trie.hasSlice(named: named, rootPath: resolvedPath)
    }
    
    /// Creates a new ZTronRouter starting from two distinct routers, if possible.
    ///
    /// - Parameter to: the router to merge this router to.
    /// - Parameter transformInfo: Maps the router informations of the two routers to the informations of the merged one.
    /// - Parameter transformOutput: For each absolute path with a registered output for at least one of the merged routers,
    ///  it maps the output of the two routers to the output of the result.
    /// - Parameter transformParameters: For each route with an associated parameter in at least one of the two merged router,
    /// it maps the parameters of the two routers to the parameter of the result. Return nil to ignore the pair.
    ///
    /// In order to be able to create a new router, the following conditions are necessary:
    /// - If the two routers have at least one registered path, the two routers must share the same root symbol.
    ///
    /// - Complexity: **Time:** O(V⋅Set<PathComponents>.insert.cost(d)) to merge the tries, and additional O(V) to map parameters. **Memory:** O(V).
    public func merge<RHSInfo, RHSOutput, RHSParameter, ResultInfo, ResultParameter, ResultOutput>(
        to otherRouter: ZTronRouter<RHSInfo, RHSOutput, RHSParameter>,
        transformInfo: @escaping (
            _ lhsInfo: RouterInfo,
            _ rhsInfo: RHSInfo
        ) throws -> ResultInfo = { (lhsInfo: RouterInfo, rhsInfo: RHSInfo) in
            return (lhsInfo, rhsInfo)
        },
        transformOutput: @escaping (
            _ absolutePath: [String],
            _ lhsOutput: RouterOutput?,
            _ rhsOutput: RHSOutput?
        ) throws -> ResultOutput = { (absolutePath: [String], lhsOutput: RouterOutput?, rhsOutput: RHSOutput?) in
            return (lhsOutput, rhsOutput)
        },
        transformParameters: @escaping (
            _ absolutePath: [String],
            _ lhsParam: RouteParameter?,
            _ rhsParam: RHSParameter?
        ) throws -> ResultParameter? = { (absolutePath: [String], lhsParam: RouteParameter?, rhsParam: RHSParameter?) in
            return (lhsParam, rhsParam)
        }
    ) rethrows -> ZTronRouter<ResultInfo, ResultOutput, ResultParameter>? {
        
        let mergedTrie = try self.trie.merge(
            to: otherRouter.trie,
            transformOutput
        )
        
        let newRouterInfo = try transformInfo(self.routerInfo, otherRouter.routerInfo)
        
        guard let newRouter = ZTronRouter<ResultInfo, ResultOutput, ResultParameter>(
            routerInfo: newRouterInfo,
            withTrie: mergedTrie
        ) else {
            return nil
        }
        
        var routesSet = Set<ZTronNavigator.PathComponents>()
        self.forEach { absolutePath, _ in
            routesSet.insert(absolutePath)
        }
        
        for absolutePath in routesSet {
            let myParamForCurrentRoute = self.getParameter(for: absolutePath)
            let otherParamForCurrentRoute = otherRouter.getParameter(for: absolutePath)
            
            if myParamForCurrentRoute != nil || otherParamForCurrentRoute != nil {
                if let newParam = try transformParameters(absolutePath, myParamForCurrentRoute, otherParamForCurrentRoute) {
                    newRouter.params[absolutePath] = newParam
                }
            }
        }
        
        return newRouter
    }
    
    /// Compares the constant routes of this router with the routes of another trie.
    ///
    /// - parameter otherTrie: The trie to compare against
    /// - Returns: `true` if both tries share the same sets of routes with an associated output, `false` otherwise
    ///
    /// - Complexity: **Time:** Let V = max(V1, V2) and b = max(b1, b2), then the time complexity
    /// is O(V⋅b⋅log(b)) to sort the routes of both tries, O(V) to compare the routes. **Memory:**  O(V).
    public func sharesRoutes<RHSRoutesInfo, RHSOutput, RHSParams>(with: ZTronRouter<RHSRoutesInfo, RHSOutput, RHSParams>) -> Bool {
        return self.trie.sharesRoutes(with: with.trie)
    }
    
    /// Tests whether or not this router (constant) registered routes are a superset of all the (constant) registered routes in `other`.
    ///
    /// - Parameter other: The supposed subset of `self`.
    /// - Returns: `true` if all the (constant) routes in `other` with an associated output, also have an associated output in `self`.
    /// `false` otherwise.
    ///
    /// - Complexity: **Time:** O(other.V) assuming `other.d << other.V`. **Memory:** O(1).
    public func isSuperSet<RHSRoutesInfo, RHSOutput, RHSParams>(
        of other: ZTronRouter<RHSRoutesInfo, RHSOutput, RHSParams>
    ) -> Bool {
        return self.trie.isSuperSet(of: other.trie)
    }
    
    public func toDOT() -> String {
        return self.trie.toDOT { absolutePath, output in
            return absolutePath.last!
        }
    }
    
    public func reduceNeighbours<T>(
        of parentPath: ZTronNavigator.PathComponents = [],
        _ initialValue: @autoclosure () -> T,
        _ transform: @escaping (_ partialResult: T, _ absolutePath: [String], _ output: RouterOutput) throws -> T
    ) rethrows -> T {
        let path = resolvePaths(self.path, parentPath)
        return try self.trie.reduceNeighbours(parentPath: path, initialValue(), transform)
    }
}
