//: [Previous](@previous)

import Foundation

var realMap = readInput(filename: "day8_input")
var testMap1 = """
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
"""


var testMap2 = """
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"""

var testMapPart2 = """
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"""


var steps: String = ""

func parseMap(map: String) -> [String:(String,String)]
{
    var lines = splitIntoLines(map)
    steps = String(lines.removeFirst())

    var paths:  [String:(String,String)] = [:]

    let re = /(?'from'[A-Z12]{3}) = \((?'left'[A-Z12]{3}), (?'right'[A-Z12]{3})\)/
    for line in lines {
        if line.isEmpty {
            continue
        }
        if let matches = try! re.wholeMatch(in: line) {
            paths[String(matches.from)] = (left: String(matches.left), right: String(matches.right))
        }
        else {
            print("Unmatched line \(line)")
        }
    }

    return paths
}

func part1(map: String) -> Int
{
    let paths = parseMap(map: map)
    var stepcount = 0

    var currPlace = "AAA"
    repeat {
        for step in steps {
            if let (left, right) = paths[currPlace] {
                if step == "L" {
                    currPlace = left
                }
                else if step == "R" {
                    currPlace = right
                }
                else {
                    assertionFailure("What, not left or right?")
                }
                stepcount += 1
                if currPlace == "ZZZ" {
                    break
                }
            }
        }
    }
    while currPlace != "ZZZ"


    return stepcount
}


/*
 Returns the Greatest Common Divisor of two numbers.
 */
func gcd(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)
    while r != 0 {
            a = b
            b = r
            r = a % b
        }
    return b
}
/*
 Returns the least common multiple of two numbers.
 */
func lcm(_ x: Int, _ y: Int) -> Int {
    return x / gcd(x, y) * y
}


func part2(map: String) -> Int
{
    let paths = parseMap(map: map)
    var stepcount = 0

    var currPlaces: [String] = []

    for place in paths.keys {
        if place.last == "A" {
            currPlaces.append(place)
        }
    }
    print("Running \(currPlaces.count) paths simultaneously.")


    func findNext(step: Character, placeIdx: Int) -> Int
    {
        if let (left, right) = paths[currPlaces[placeIdx]] {
            if step == "L" {
                currPlaces[placeIdx] = left
            }
            else if step == "R" {
                currPlaces[placeIdx] = right
            }
            else {
                assertionFailure("What, not left or right?")
            }
            if currPlaces[placeIdx].last == "Z" {
                return 1
            }
            return 0
        }
        else {
            assertionFailure("I found nowhere to go for place \(currPlaces[placeIdx])")
        }
        return 0
    }

    var stepsForPlaces:[Int] = Array(repeating: 0, count: currPlaces.count)

    var reachedZ = 0
    repeat {
        for step in steps {
            stepcount += 1
            for currPlace in 0..<currPlaces.count {
                var reached = findNext(step: step, placeIdx: currPlace)
                if reached == 1 {
                    if stepsForPlaces[currPlace] == 0 {
                        stepsForPlaces[currPlace] = stepcount
                        reachedZ += 1
                    }
                }
            }

            if reachedZ == currPlaces.count {
                break
            }
        }
    }
    while reachedZ != currPlaces.count;


    var stepsLcm = stepsForPlaces[0]
    for sfp in stepsForPlaces[1...] {
        stepsLcm = lcm(stepsLcm, sfp)
    }

    return stepsLcm
}


runMeasured(part1, with: realMap)

runMeasured(part2, with: realMap)


//: [Next](@next)
