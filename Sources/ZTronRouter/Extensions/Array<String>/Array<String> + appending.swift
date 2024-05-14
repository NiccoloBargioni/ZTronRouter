import Foundation

public extension Array where Element == String {
    func appending(contentsOf: [String]) -> [String] {
        var selfCopy = Array(self)
        selfCopy.append(contentsOf: contentsOf)
        return selfCopy
    }
    
    func appending(newElement: String) -> [String] {
        return self.appending(contentsOf: [newElement])
    }
}
