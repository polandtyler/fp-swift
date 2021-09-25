/**
 Sources:
 - https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols/ep34-protocol-witnesses-part-2
 */

import Foundation

// How do we address the "multiple conformance" issue?
/**
 It turns out that when you define a protocol in Swift and conform a type to that protocol, the compiler is doing something very special under the hood in order to track the relationship between those two things. We are going to give a precise definition to that construction, and we will even recreate it directly in Swift code. This will mean that we are going to do the work that the compiler could be doing for us for free, but by us taking the wheel for this we will get a ton of flexibility and composability out of it.
 */

// Refresher: Here is the Describable protocol defined previously:
protocol Describable {
    var describe: String { get }
}

extension Int: Describable {
    var describe: String {
        return "\(self)"
    }
}

extension DBConnectionInfo: Describable {
    var describe: String {
        return "database://\(self.user):\(self.password)@\(self.hostname):\(self.port)/\(self.database)"
    }
}

// here's the conn info we will use in this tut
// as well as conformance to describable
let localhost = DBConnectionInfo(
    database: "tyler_development",
    hostname: "localhost",
    password: "some value",
    port: 8080,
    user: "tyler"
)

// Let's "de-protocolize" this into a generic struct where the generic type
// represents the type conforming to the protocol,
// Then the struct will have fields corresponding to the requirements of the protocol
// uncomment this until you reach line 146
//struct Describing<A: Describable> {
//    var describe: (A) -> String
//}

// from the Describing type, we create instances, which are called "witnesses" to the protocol conformance
//let compactWitness = Describing<DBConnectionInfo> { conn in
//    "DBConnectionInfo(database: \"\(conn.database)\", hostname: \"\(conn.hostname)\", password: \"\(conn.password)\", port: \"\(conn.port)\", user: \"\(conn.user)\")"
//}

//print(compactWitness.describe(localhost))
// DBConnectionInfo(database: "tyler_development", hostname: "localhost", password: "", port: "8080", user: "tyler")

let prettyWitness = Describing<DBConnectionInfo> {
      """
      DBConnectionInfo(
        database: \"\($0.database)",
        hostname: \"\($0.hostname)",
        password: \"\($0.password)",
        port: \"\($0.port)",
        user: \"\($0.user)"
      )
      """
}
print(prettyWitness.describe(localhost))

let connectionWitness = Describing<DBConnectionInfo> {
    "database://\($0.user):\($0.password)@\($0.hostname):\($0.port)/\($0.database)"
}
print(connectionWitness.describe(localhost))

func print<T>(tag: String, _ value: T, _ witness: Describing<T>) {
    print("[\(tag)] \(witness.describe(value))")
}

let tag = "debug"
print(tag: tag, localhost, connectionWitness)
print(tag: tag, localhost, prettyWitness)
//print(tag: tag, localhost, compactWitness)

// if we were to write this using protocols instead of protocol witnesses:
// important to note that here we are constrained to a single conformance
// to the `Describable` protocol
func print<T: Describable>(tag: String, _ value: T) {
    print("[\(tag)] \(value.describe)")
}
print(tag: tag, localhost)

// De-protocolizing Combinable
protocol Combinable {
    func combine(with other: Self) -> Self
}

struct Combining<T> {
    let combine: (T, T) -> T
}

// De-protocolizing EmptyInitializable
protocol EmptyInitializable {
    init()
}

struct EmptyInitializing<T> {
    let create: () -> T
}

extension Array {
    func reduce(_ initial: Element, _ combining: Combining<Element>) -> Element {
        return self.reduce(initial, combining.combine)
    }
}
// so now we can define multiple witnesses
let sum = Combining<Int>(combine: +)
[1,2,3,4].reduce(0, sum) // 10

let product = Combining<Int>(combine: *)
[1,2,3,4].reduce(1, product) // 24

// remember when we did this?
extension Array where Element: Combinable & EmptyInitializable {
    func reduce() -> Element {
        return self.reduce(Element()) { $0.combine(with: $1) }
    }
}

// well now, it can look like:
extension Array {
    func reduce(_ initial: EmptyInitializing<Element>, _ combining: Combining<Element>) -> Element {
        return self.reduce(initial.create(), combining.combine)
    }
}

let zero = EmptyInitializing<Int> { return 0 }
[1,2,3,4].reduce(zero, sum) // 10

let one = EmptyInitializing<Int> { return 1 }
[1,2,3,4].reduce(one, product) // 24

// Why should we do this?
// For starters, this is what the Swift compiler is doing under the hood so there's basically no difference, and you dont have to lean on compiler black magic!
// Second, explicit witnesses give us a whole new level of composability with our conformances that was impossible to see when dealing with protocols

// WITNESS COMPOSITION
//struct Describing<A> {
//    let describe: (A) -> String
//
//    // "if you tell me how to transform B's into T's, contramap can then transform Describing<A>'s into Describing<B>'s"
//    // basically, this lets youcreate all new witnesses of the protocol FROM existing witnesses
//    func contramap<B>(_ f: @escaping (B) -> A) -> Describing<B> {
//        return Describing<B> { b in
//          self.describe(f(b))
//        }
//      }
//}
struct Describing<A> {
    let describe: (A) -> String
    
    func contramap<B>(_ f: @escaping (B) -> A) -> Describing <B> {
        return Describing<B> { b in
            self.describe(f(b))
        }
    }
}

let compactWitness = Describing<DBConnectionInfo> {
    "DBConnectionInfo(database: \"\($0.database)\", hostname: \"\($0.hostname)\", password: \"\($0.password)\", port: \"\($0.port)\", user: \"\($0.user)\")"
}

let secureCompactWitness: Describing<DBConnectionInfo> = compactWitness.contramap {
    DBConnectionInfo(database: $0.database,
                     hostname: $0.hostname,
                     password: "******",
                     port: $0.port,
                     user: $0.user)
}
print("secure: \(secureCompactWitness.describe(localhost))")

let securePrettyWitness: Describing<DBConnectionInfo> = prettyWitness.contramap {
    DBConnectionInfo(database: $0.database, hostname: $0.hostname, password: "*******", port: $0.port, user: $0.user)
}
print(securePrettyWitness.describe(localhost))


