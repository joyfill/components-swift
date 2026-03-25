import Foundation


public struct JSONPointer {
  var components: [String]

  init() {
    components = [""]
  }

  init(path: String) {
    components = path
      .components(separatedBy: "/")
      .map {
        guard $0.contains("~") else { return $0 }
        return $0.replacingOccurrences(of: "~1", with: "/").replacingOccurrences(of: "~0", with: "~")
      }
  }

  public var path: String {
    return components
      .map {
        guard $0.contains("~") || $0.contains("/") else { return $0 }
        return $0
          .replacingOccurrences(of: "~", with: "~0")
          .replacingOccurrences(of: "/", with: "~1")
      }
      .joined(separator: "/")
  }

  func resolve(document: Any) -> Any? {
    if components.isEmpty {
      return document
    }

    var instance = document
    for component in components[1...] {
      if let document = instance as? [String: Any], let value = document[component] {
        instance = value
        continue
      }

      if let document = instance as? [Any], let index = UInt(component), index < document.count {
        instance = document[Int(index)]
        continue
      }

      return nil
    }

    return instance
  }

  mutating func push(_ component: String) {
    // Most property keys contain no escape sequences — skip the replace work.
    if component.contains("~") {
      components.append(
        component
          .replacingOccurrences(of: "~1", with: "/")
          .replacingOccurrences(of: "~0", with: "~")
      )
    } else {
      components.append(component)
    }
  }

  mutating func pop() {
    components.removeLast()
  }
}


func + (lhs: JSONPointer, rhs: String) -> JSONPointer {
  var pointer = lhs
  pointer.components.append(rhs)
  return pointer
}
