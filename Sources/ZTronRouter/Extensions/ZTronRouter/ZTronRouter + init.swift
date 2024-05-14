import Foundation
import RoutingKit

public class Empty { }

extension ZTronRouter where RouterInfo == Empty {
    public convenience init() {
        self.init(routerInfo: Empty())
    }
}

extension ZTronRouter {
    internal convenience init?(
        routerInfo: RouterInfo,
        withTrie: TrieRouter<RouterOutput>
    ) {
        self.init(routerInfo: routerInfo)

        withTrie.forEach { [weak self] absolutePath, output in
            guard let self = self else { return }

            if absolutePath.count > self.maxDepth {
                self.maxDepth = absolutePath.count
            }
            
            self.registeredRoutesCount += 1
        }
     
        if registeredRoutesCount > 0 {
            guard withTrie.hasSlice(named: self.navigator.getRootSymbol()) else {
                print("Attempted to initialize a new ZTronRouter from a trie that doesn't contain \(self.navigator.getRootSymbol())")
                return nil
            }
        }
        
        self.trie = withTrie
    }
}

