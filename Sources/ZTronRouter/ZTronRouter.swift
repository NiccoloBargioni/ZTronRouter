import Foundation
import RoutingKit
import Combine

/// Represents a path-based object router. Every router may or may not have a descriptor of type `RouterInfo`. Please use
/// `ZTronRouter.Empty` to signal a router with no description.
public final class ZTronRouter<RouterInfo, RouterOutput, RouteParameter>: ObservableObject {
    
    @Published internal var navigator: ZTronNavigator = ZTronNavigator()
    internal var trie: TrieRouter<RouterOutput> = TrieRouter<RouterOutput>()
    internal var params: [ZTronNavigator.PathComponents: RouteParameter] = [:]
    internal var routerInfo: RouterInfo
    
    internal var registeredRoutesCount: Int = 0
    internal var maxDepth: Int = 0

    internal var subscriptions: Set<AnyCancellable> = Set()

    public init(routerInfo: RouterInfo) {
        self.routerInfo = routerInfo

        self.navigator.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        .store(in: &self.subscriptions)
    }
    
    deinit {
        self.subscriptions.forEach { cancellable in
            cancellable.cancel()
        }
    }

    public func getInfo() -> RouterInfo {
        return self.routerInfo
    }
    
    public func getMaxDepth() -> Int {
        return self.maxDepth
    }
    
    public func getRoutesCount() -> Int {
        return self.registeredRoutesCount
    }
    
    public func getParameter(for route: ZTronNavigator.PathComponents) -> RouteParameter? {
        return self.params[route]
    }
}
