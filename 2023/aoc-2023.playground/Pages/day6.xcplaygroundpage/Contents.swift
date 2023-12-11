//: [Previous](@previous)

import Foundation

let realRaces = """
Time:        54     81     70     88
Distance:   446   1292   1035   1007
"""

let testRaces = """
Time:      7  15   30
Distance:  9  40  200
"""


struct Race
{
    var time: Int
    var dist: Int
}

func parseRaces(races: String) -> [Race]
{
    var raceList : [Race] = []

    let re = /(?'desc'[A-Za-z]+):|(?'num'[0-9]+)/
    for line in splitIntoLines(races) {
        let matches = line.matches(of: re)
        if let desc = matches[0].desc {
            if desc == "Time" {
                for match in matches[1...] {
                    raceList.append(Race(time: Int(match.num!)!, dist: 0))
                }
            }
            else if desc == "Distance" {
                var pos = 0
                for match in matches[1...] {
                    raceList[pos].dist = Int(match.num!)!
                    pos += 1
                }
            }
            else {
                assertionFailure("Unexpected value for line description: \(desc)")
            }
        }
    }

    return raceList
}



let races = parseRaces(races: realRaces)

func part1() -> Int
{
    var margin = 1
    for race in races {
        var winningTimes = 0
        let maxTime = race.time / 2

        for i in 1...maxTime {
            let dist = i * (race.time - i)
            if dist > race.dist {
                winningTimes += 1
            }
        }
        if race.time.isMultiple(of: 2) {
            winningTimes = (winningTimes - 1) * 2
            winningTimes += 1
        }
        else {
            winningTimes *= 2
        }

        print("Possible ways to win: \(winningTimes)")
        margin *= winningTimes
    }

    return margin
}


func part2() -> Int
{
    var winningTimes = 0

    var time = 0
    var distance = 0

    for race in races {
        var magnitude = 0
        var rtime = race.time
        while rtime > 0 {
            magnitude += 1
            rtime /= 10
        }
        for _ in 1...magnitude {
            time *= 10
        }
        time += race.time

        magnitude = 0
        var rdist = race.dist
        while rdist > 0 {
            magnitude += 1
            rdist /= 10
        }
        for _ in 1...magnitude {
            distance *= 10
        }
        distance += race.dist
    }

    print("Race time is \(time) and distance is \(distance)")
    let maxTime = time / 2
    print("\nMax time is \(maxTime), max distance is \(maxTime * (time - maxTime) )")
    var minTime = 0

    var lowerBound = 1
    var upperBound = maxTime

    var iterations = 0
    while lowerBound < (upperBound-1) {
        iterations += 1
        var mid = lowerBound + ((upperBound - lowerBound) / 2)
        var dist = mid * (time - mid)
        if dist <= distance {
            lowerBound = mid
        }
        else {
            upperBound = mid
        }

        if (time - lowerBound) * lowerBound <= distance && (time - (lowerBound+1)) * (lowerBound+1) > distance {
            minTime = lowerBound + 1
            break
        }
        if (time - upperBound) * upperBound > distance && (time - (upperBound-1)) * (upperBound-1) < distance {
            minTime = upperBound
            break
        }
    }
    if minTime == 0 {
        minTime = upperBound
    }

    if time.isMultiple(of: 2) {
        winningTimes = maxTime - minTime
        winningTimes *= 2
        winningTimes += 1
    }
    else {
        winningTimes = (maxTime - minTime) + 1
        winningTimes *= 2
    }

    return winningTimes
}


runMeasured(part1)
runMeasured(part2)

//: [Next](@next)
