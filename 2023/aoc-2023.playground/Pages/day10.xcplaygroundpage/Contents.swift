//: [Previous](@previous)

import Foundation

let realMap = readInput(filename: "day10_input")

let testMap1  = """
.....
.S-7.
.|.|.
.L-J.
.....
"""

let testMap2  = """
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
"""

let testMap3 = """
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
"""

let testMap4 = """
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
"""

let testMap5 = """
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
"""

let testMap6 = """
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
"""

let testMap7 = """
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
"""


func toLines(_ str: String) -> [String]
{
    return str.components(separatedBy: "\n")
}


func findStart(mapLines: [String]) -> (Int,Int)
{
    for y in 0..<mapLines.count {
        if let x = mapLines[y].firstIndex(of: "S") {
            return (mapLines[y].distance(from: mapLines[y].startIndex, to: x),y)
        }
    }
    return (0, 0)
}

func findStartConnections(map: [String], pos: (Int,Int)) -> ((Int,Int),(Int,Int))
{
    var line = map[pos.1]
    var x = line.index(line.startIndex, offsetBy: pos.0)

    var firstConnection : (Int,Int)?

    // Check in the same line, i.e. horizontal
    if (x > line.startIndex) {
        let c = line[line.index(before: x)]
        if (c == "L" || c == "-" || c == "F" ) {
            firstConnection = (pos.0 - 1, pos.1)
        }
    }

    if (x < line.index(before: line.endIndex)) {
        let c = line[line.index(after: x)]
        if (c == "J" || c == "-" || c == "7" ) {
            if (firstConnection == nil) {
                firstConnection = (pos.0 + 1, pos.1)
            }
            else {
                return (firstConnection!, (pos.0 + 1, pos.1))
            }
        }
    }

    // Check the vertical line, i.e. above and below
    if (pos.1 > 0) {
        line = map[pos.1 - 1]
        x = line.index(line.startIndex, offsetBy: pos.0)
        let c = line[x]
        if (c == "7" || c == "|" || c == "F" ) {
            if (firstConnection == nil) {
                firstConnection = (pos.0, pos.1 - 1)
            }
            else {
                return (firstConnection!, (pos.0, pos.1 - 1))
            }
        }
    }

    if (pos.1 < map.endIndex-1) {
        line = map[pos.1 + 1]
        x = line.index(line.startIndex, offsetBy: pos.0)
        let c = line[x]
        if (c == "J" || c == "|" || c == "L" ) {
            if (firstConnection == nil) {
                assertionFailure("There must be a first connection at this point")
            }
            return (firstConnection!, (pos.0, pos.1 + 1))
        }
    }

    assertionFailure("No two connections were found")
    return ((0,0),(0,0))
}

func step(_ map: [String], from: (Int,Int), at: (Int,Int)) -> (Int,Int)
{
    let line = map[at.1]
    let x = line.index(line.startIndex, offsetBy: at.0)
    let c = line[x]

    switch(c) {
    case "-":
        return from.0 < at.0 /*coming from left*/ ? (at.0+1,at.1) /*go right*/ : (at.0-1,at.1) /* go left*/
    case "7":
        nodes.append(at)
        return from.0 < at.0 /*coming from left*/ ? (at.0,at.1+1) /*go down*/ : (at.0-1,at.1) /*go left*/
    case "|":
        return from.1 < at.1 /*coming from above*/ ? (at.0,at.1+1) /*go down*/ : (at.0,at.1-1) /*go up*/
    case "J":
        nodes.append(at)
        return from.1 < at.1 /*coming from above*/ ? (at.0-1,at.1) /*go left*/ : (at.0,at.1-1) /*go up*/
    case "L":
        nodes.append(at)
        return from.0 > at.0 /*coming from right*/ ? (at.0,at.1-1) /*go up*/ : (at.0+1,at.1) /*go right*/
    case "F":
        nodes.append(at)
        return from.1 > at.1 /*coming from below*/ ? (at.0+1,at.1) /*go right*/ : (at.0,at.1+1) /*go down*/
    case "S":
        print("Stepped back onto start")
        return (at.0,at.1)
    default:
        assertionFailure("This is an unknown pipe symbol: \(c)")
    }
    return (-1,-1)
}


var steps = 0
var nodes : [(Int,Int)] = Array()

func part1(map: String) -> Int
{
    let mapLines = toLines(map)
    let start = findStart(mapLines: mapLines)

    print("Start is at \(start.0), \(start.1)")
    let (connOne, connTwo) = findStartConnections(map: mapLines, pos: start)

    print("Start has two connections: \(connOne.0),\(connOne.1) and \(connTwo.0),\(connTwo.1)")

    let maxSteps = mapLines.count * mapLines[0].count


    nodes.append(start)
    var from = start
    steps = 1
    var at = connOne
    while (at != start && steps < maxSteps) {
        var to = step(mapLines, from: from, at: at )
        from = at
        at = to
        steps += 1
    }

    return steps / 2
}


func part2() -> Int
{
    print("Polygon with \(nodes.count) nodes")

    var A = 0
    // Calculate area of polygon with Gauss' shoelace formula
    for i in 0..<nodes.count {
        var ip1 = (i + 1) % nodes.count
        A += (nodes[i].1 + nodes[ip1].1) * (nodes[i].0 - nodes[ip1].0)
    }
    if (A < 0) {
        A = -A
    }
    A = A / 2

    print ("Area in polygon is \(A)")

    // Calculate inner points in grid polygon with Pick's theorem: A = I + R/2 -1
    // => I = A +1 - R/2
    var I = A + 1
    I = I - (steps / 2)

    return I
}



runMeasured(part1, with: realMap)
runMeasured(part2)
//: [Next](@next)
