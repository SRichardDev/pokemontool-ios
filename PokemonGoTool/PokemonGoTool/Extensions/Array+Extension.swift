
import Foundation

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if !contains(element) {
            append(element)
            return (true, element)
        }
        return (false, element)
    }
}

extension Array where Element == Pokestop {
    mutating func replace(object: Element) {
        if let index = firstIndex(where: {$0.id == object.id}) {
            self[index] = object
        }
    }
}

extension Array where Element == Arena {
    mutating func replace(object: Element) {
        if let index = firstIndex(where: {$0.id == object.id}) {
            self[index] = object
        }
    }
}
