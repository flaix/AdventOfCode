//: [Previous](@previous)

import Foundation

var realReport = readInput(filename: "day9_input")

var testReport = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""



func parseReport(_ str: String) -> [[Int]]
{
    var histories : [[Int]] = []

    let lines = splitIntoLines(str)
    for line in lines {
        if line.isEmpty {
            continue
        }
        var strHistory = line.split(separator: " ")
        histories.append(strHistory.map { Int($0)! })
    }

    return histories
}


func solve(_ history: [Int]) -> [Int]
{
    var solver = [history]
    var curLine = 0
    var sum = 0

    repeat {
        sum = 0
        var diffs : [Int] = []
        for pos in 1..<solver[curLine].count {
            var diff = solver[curLine][pos] - solver[curLine][pos-1]
            diffs.append(diff)
            sum += diff
        }
        solver.append(diffs)
        curLine += 1
    } while (sum != 0)

    solver[curLine].append(0)
    curLine -= 1
    while (curLine >= 0) {
        solver[curLine].append(solver[curLine].last! + solver[curLine+1].last!)
        solver[curLine].insert(solver[curLine].first! - solver[curLine+1].first!, at: 0)
        curLine -= 1
    }

//    print("Solver layers: \(solver.count)")
//    print("Solver last: \(solver[0].last!)")
//    print("Solver first: \(solver[0].first!)")


    return solver[0]
}


func part1(report: String) -> Int
{
    let histories = parseReport(report)

    var sum = 0

    for history in histories {
        sum += solve(history).last!
    }
    return sum
}

func part2(report: String) -> Int
{
    let histories = parseReport(report)

    var sum = 0

    for history in histories {
        sum += solve(history).first!
    }
    return sum
}



runMeasured(part1, with: realReport)
runMeasured(part2, with: realReport)

//: [Next](@next)
