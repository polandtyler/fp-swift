import Foundation


enum RideCategory: String, CustomStringConvertible {
    case family, kids, thrill, scary, relaxing, water
    
    var description: String {
        return rawValue
    }
}

typealias Minutes = Double
struct Ride: CustomStringConvertible {
    let name: String
    let categories: Set<RideCategory>
    let waitTime: Minutes
    
    var description: String {
        return "Ride -\"\(name)\", wait: \(waitTime) mins, " + "categories: \(categories)\n"
    }
}

let parkRides = [
    Ride(name: "Raging Rapids", categories: [.family, .thrill, .water], waitTime: 10.0),
    Ride(name: "Crazy Funhouse", categories: [.family], waitTime: 15.0),
    Ride(name: "Spinning Tea Cups", categories: [.kids], waitTime: 15.0),
    Ride(name: "Spooky Hollow", categories: [.scary], waitTime: 30.0),
    Ride(name: "Thunder Coaster", categories: [.family, .thrill], waitTime: 15.0),
    Ride(name: "Grand Carousel", categories: [.family, .kids], waitTime: 15.0),
    Ride(name: "Bumper Boats", categories: [.family, .water], waitTime: 25.0),
    Ride(name: "Mountain Railroad", categories: [.family, .relaxing], waitTime: 0.0)
]

func sortedNames(of rides: [Ride]) -> [String] {
    var sortedRides = rides
    var key: Ride
    
    for i in (0..<sortedRides.count) {
        key = sortedRides[i]
        
        for j in stride(from: i, to: -1, by: -1) {
            if key.name.localizedCompare(sortedRides[j].name) == .orderedAscending {
                sortedRides.remove(at: j + 1)
                sortedRides.insert(key, at: j)
            }
        }
    }
    
    var sortedNames: [String] = []
    for ride in sortedRides {
        sortedNames.append(ride.name)
    }
    
    return sortedNames
}

let sortedNames1 = sortedNames(of: parkRides)

func testSortedNames(_ names: [String]) {
    let expected = ["Bumper Boats",
                    "Crazy Funhouse",
                    "Grand Carousel",
                    "Mountain Railroad",
                    "Raging Rapids",
                    "Spinning Tea Cups",
                    "Spooky Hollow",
                    "Thunder Coaster"]
    assert(names == expected)
    print("✅ test sorted names = PASS\n-")
}

testSortedNames(sortedNames1)

var originalNames: [String] = []
for ride in parkRides {
    originalNames.append(ride.name)
}

func testOriginalNameOrder(_ names: [String]) {
    let expected = ["Raging Rapids",
                    "Crazy Funhouse",
                    "Spinning Tea Cups",
                    "Spooky Hollow",
                    "Thunder Coaster",
                    "Grand Carousel",
                    "Bumper Boats",
                    "Mountain Railroad"]
    assert(names == expected)
    print("✅ test original name order = PASS\n-")
}

testOriginalNameOrder(originalNames)

let apples = ["🍎", "🍏", "🍎", "🍏", "🍏"]
let greenApples = apples.filter { $0 == "🍏" }

// think about WHAT you want to happen instead of HOW
func waitTimeIsShort(_ ride: Ride) -> Bool {
    return ride.waitTime < 15.0
}
let shortWaitTimes = parkRides.filter(waitTimeIsShort)

let shortWaitTimeRides = parkRides.filter { $0.waitTime < 15.0 }.map { $0.name }

let oranges = apples.map { _ in "🍊" }

let rideNames = parkRides.map { $0.name }
testOriginalNameOrder(rideNames)

func sortedNamesFP(_ rides: [Ride]) -> [String] {
    return rides.map { $0.name }.sorted(by: <)
}

let sortedNames2 = sortedNamesFP(parkRides)
testSortedNames(sortedNames2)

let juice = oranges.reduce("") { juice, orange in juice + "🍹" }

let totalWaitTime = parkRides.reduce(0.0) { total, ride  in
    return total + ride.waitTime
}

// function that returns a function
func filter(for category: RideCategory) -> ([Ride]) -> [Ride] {
    return { rides in
        rides.filter { $0.categories.contains(category) }
    }
}

let kidRideFilter = filter(for: .kids)

func ridesWithWaitTimeUnder(_ waitTime: Minutes, from rides: [Ride]) -> [Ride] {
    return rides.filter { $0.waitTime < waitTime }
}
let shortWaitRides = ridesWithWaitTimeUnder(15, from: parkRides)

func testShortWaitRides(_ testFilter: (Minutes, [Ride]) -> [Ride]) {
    let limit = Minutes(15)
    let result = testFilter(limit, parkRides)
    let names = result.map { $0.name }.sorted(by: <)
    let expected = ["Mountain Railroad", "Raging Rapids"]
    assert(names == expected)
    print("✅ test rides with wait time under 15 = PASS\n-")
}

testShortWaitRides(ridesWithWaitTimeUnder(_:from:))

testShortWaitRides({ waitTime, rides in
    return rides.filter { $0.waitTime < waitTime }
})

extension Ride: Comparable {
    public static func <(lhs: Ride, rhs: Ride) -> Bool {
        return lhs.waitTime < rhs.waitTime
    }
    
    public static func ==(lhs: Ride, rhs: Ride) -> Bool {
        return lhs.name == lhs.name
    }
}


extension Array where Element: Comparable {
    func quickSorted() -> [Element] {
        if self.count > 1 {
            let (pivot, remaining) = (self[0], dropFirst())
            let lhs = remaining.filter { $0 <= pivot }
            let rhs = remaining.filter { $0 > pivot }
            return lhs.quickSorted() + [pivot] + rhs.quickSorted()
        }
        return self
    }
}


let quickSortedRides = parkRides.quickSorted()

func testSortedByWaitRides(_ rides: [Ride]) {
    let expected = rides.sorted(by: { $0.waitTime < $1.waitTime })
    assert(rides == expected, "Unexpected order")
    print("✅ test sorted by wait time = PASS\n-")
}
testSortedByWaitRides(quickSortedRides)

//Solving the problem with imperative approach
var ridesOfInterest: [Ride] = []
for ride in parkRides where ride.waitTime < 20 {
    for category in ride.categories where category == .family {
        ridesOfInterest.append(ride)
        break
    }
}

let sortedRidesOfInterestIMP = ridesOfInterest.quickSorted()

// solving with an FP approach
let sortedRidesOfInterestFP = parkRides
    .filter { $0.categories.contains(.family) && $0.waitTime < 20 }
    .sorted(by: <)

enum Implementation: String {
    case functional, imperative
}

typealias TestOutcome = Bool

func testResultString(_ testName: String, result: TestOutcome, impl: Implementation) -> String {
    let endString = result == true ? "PASS\n-" : "FAIL\n-"
    let emoji = result == true ? "✅" : "❌"
    return "\(emoji) \(testName) \(impl.rawValue.capitalized) = \(endString)"
}

func testSortedRidesOfInterest(_ rides: [Ride], _ impl: Implementation) {
    let names = rides.map { $0.name }.sorted(by: <)
    let expected = ["Crazy Funhouse",
                    "Grand Carousel",
                    "Mountain Railroad",
                    "Raging Rapids",
                    "Thunder Coaster"
    ]
    let result = (names == expected)
    print(testResultString("Test Rides of Interest", result: result, impl: impl))
}

testSortedRidesOfInterest(sortedRidesOfInterestIMP, .imperative)
testSortedRidesOfInterest(sortedRidesOfInterestFP, .functional)
