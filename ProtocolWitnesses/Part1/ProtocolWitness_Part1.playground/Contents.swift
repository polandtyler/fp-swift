/**
 Credit:
 - https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols/ep33-protocol-witnesses-part-1
 */

import UIKit

protocol Describable {
    var describe: String { get }
}

extension Int: Describable {
    var describe: String {
        return "\(self)"
    }
}
2.describe

protocol EmptyInitializable {
    init()
}

extension String: EmptyInitializable {}
extension Int: EmptyInitializable {
    init() {
        self = 1
    }
}
extension Array: EmptyInitializable {}
extension Optional: EmptyInitializable {
    init() {
        self = nil
    }
}

[1,2,3].reduce(0, +)

extension Array {
    func reduce<Result: EmptyInitializable>(_ accumulation: (Result, Element) -> Result) -> Result {
        return self.reduce(Result(), accumulation)
    }
}
[1,2,3].reduce(+) // 6
[[1, 2], [], [3, 4]].reduce(+) // [1, 2, 3, 4]
["Hello", " ", "there!"].reduce(+) // "Hello there!"

// COMBINABLE
protocol Combinable {
    func combine(with other: Self) -> Self
}

//extension Int: Combinable {
//    func combine(with other: Int) -> Int {
//        return self + other
//    }
//}
extension String: Combinable {
    func combine(with other: String) -> String {
        return self + other
    }
}
extension Array: Combinable {
    func combine(with other: Array<Element>) -> Array<Element> {
        return self + other
    }
}
extension Optional: Combinable {
    func combine(with other: Optional<Wrapped>) -> Optional<Wrapped> {
        return self ?? other
    }
}

extension Array where Element: Combinable {
    func reduce(_ initial: Element) -> Element {
        return self.reduce(initial) { $0.combine(with: $1) }
    }
}
[1,2,3].reduce(0) // 6
[[1, 2], [], [3, 4]].reduce([]) // [1, 2, 3, 4]
[nil, nil, 3].reduce(nil) // 3

// PROTOCOL COMPOSITION
extension Array where Element: Combinable & EmptyInitializable {
    func reduce() -> Element {
        return self.reduce(Element()) { $0.combine(with: $1) }
    }
}
[1,2,3].reduce() // 6
[[1, 2], [], [3, 4]].reduce() // [1, 2, 3, 4]
[nil, nil, 3].reduce() // 3

// The problem with protocols
extension Int: Combinable {
    func combine(with other: Int) -> Int {
        return self * other
    }
}
// 🛑 Redundant conformance of 'Int' to protocol 'Combinable'
// (uncomment 48-52 to see compiler error)
// also changed EmptyInitializable conformance for `Int` to set `self` to 1
[1,2,3].reduce() // 6 - but ok this is the same result as addition
[1,2,3,4].reduce() // 24 - its working
// but now reduce by addition doesnt work...


struct DBConnectionInfo {
    let database: String
    let hostname: String
    let password: String
    let port: Int
    let user: String
}

let localhost = DBConnectionInfo(
  database: "tyler_development",
  hostname: "localhost",
  password: "",
  port: 8080,
  user: "tyler"
)

// v1: uncomment to see
//extension DBConnectionInfo: Describable {
//  var describe: String {
//    return "PostgresConnInfo(database: \(self.database), hostname: \(self.hostname), password: \(self.password), port: \(self.port), user: \(self.user))"
//  }
//}
//print(localhost.describe)

// but now we want a pretty version
// v2: uncomment and comment out v1 to test
//extension DBConnectionInfo: Describable {
//    var describe: String {
//        return """
//DBConnectionInfo(
//  database: \"\(self.database)",
//  hostname: \"\(self.hostname)",
//  password: \"\(self.password)",
//  port: \"\(self.port)",
//  user: \"\(self.user)"
//)
//"""
//    }
//}
//print(localhost.describe)

// and now, a third use case: print out the actual connection string
// v3: comment out v1 and v2 to test
extension DBConnectionInfo: Describable {
  var describe: String {
    return "database://\(self.user):\(self.password)@\(self.hostname):\(self.port)/\(self.database)"
  }
}

print(localhost.describe)
// but which one is right???

// TO BE CONTINUED...

