//: [Previous](@previous)

import Foundation

let schematic: String?
if let input = Bundle.main.url(forResource: "day3_input", withExtension: "txt") {
    schematic = try String(contentsOf: input)
    if schematic == nil {
        exit(EXIT_FAILURE)
    }
}
else {
    exit(EXIT_FAILURE)
}

//let schematic = """
//467..114..
//...*......
//..35..633.
//......#...
//617*......
//.....+..58
//..592.....
//......755.
//...$.*....
//.664.598..
//"""


func part1(schematic: String) -> Int
{
    var sum = 0

    var prevLineSymbols: [Int] = []
    var thisLineSymbols: [Int] = []

    var prevLineNumbers: [(left:Int,right:Int, value:Int)] = []
    var thisLineNumbers: [(left:Int,right:Int, value:Int)] = []


    for line in schematic.split(separator: "\n") {
        var pos = 0
        var numLeftPos = -1
        var numRightPos = -1
        var num = 0

        thisLineNumbers = []
        thisLineSymbols = []

        for char in line {
            switch(char) {
            case let x where x.isWholeNumber:
                if numLeftPos < 0 {
                    numLeftPos = pos
                    numRightPos = pos
                    num = x.wholeNumberValue!
                }
                else {
                    numRightPos = pos
                    num = (num*10) + x.wholeNumberValue!
                }
            case ".":
                if numRightPos >= 0 {
                    thisLineNumbers.append((left:numLeftPos, right:numRightPos, value:num))
                    numLeftPos = -1
                    numRightPos = -1
                    num = 0
                }
            default:
                thisLineSymbols.append(pos)
                if numRightPos >= 0 {
                    thisLineNumbers.append((left:numLeftPos, right:numRightPos, value:num))
                    numLeftPos = -1
                    numRightPos = -1
                    num = 0
                }
            }
            pos += 1
        }
        if numRightPos >= 0 {
            thisLineNumbers.append((left:numLeftPos, right:numRightPos, value:num))
            numLeftPos = -1
            numRightPos = -1
            num = 0
        }


        // Now analyse the found numbers for adjacency to symbols
        for numble in prevLineNumbers {
            for symbolPos in thisLineSymbols {
                if numble.left-1 <= symbolPos && symbolPos <= numble.right+1 {
                    sum += numble.value
                    break
                }
            }

        }
        prevLineNumbers = []

        for numble in thisLineNumbers {
            var touches = false
            for symbolPos in prevLineSymbols {
                if numble.left-1 <= symbolPos && symbolPos <= numble.right+1 {
                    touches = true
                    break
                }
            }
            if !touches && (numble.left > 0 && thisLineSymbols.contains(numble.left-1) || thisLineSymbols.contains(numble.right+1)) {
                touches = true
            }
            if touches {
                sum += numble.value
            }
            else {
                prevLineNumbers.append(numble)
            }
        }

        prevLineSymbols = thisLineSymbols
    }


    return sum
}




extension Dictionary where Value: RangeReplaceableCollection {
    public mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) -> Value? {
        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
        return value
    }
}

func part2(schematic: String) -> Int
{
    var sum = 0

    var prevLineGears: [Int:[Int]] = [:]
    var thisLineGears: [Int:[Int]] = [:]
    var prevLineNumbers: [(left:Int,right:Int, value:Int)] = []
    var thisLineNumbers: [(left:Int,right:Int, value:Int)] = []


    for line in schematic.split(separator: "\n") {
        var numLeftPos = -1
        var numRightPos = -1
        var num = 0

        thisLineNumbers = []
        thisLineGears = [:]

        for (pos,char) in line.enumerated() {
            switch(char) {
            case let x where x.isWholeNumber:
                if numLeftPos < 0 {
                    numLeftPos = pos
                    numRightPos = pos
                    num = x.wholeNumberValue!
                }
                else {
                    numRightPos = pos
                    num = (num*10) + x.wholeNumberValue!
                }
            case ".":
                if numRightPos >= 0 {
                    thisLineNumbers.append((left:numLeftPos, right:numRightPos, value:num))
                    numLeftPos = -1
                    numRightPos = -1
                    num = 0
                }
            case "*":
                thisLineGears[pos] = []
                if numRightPos >= 0 {
                    thisLineNumbers.append((left:numLeftPos, right:numRightPos, value:num))
                    numLeftPos = -1
                    numRightPos = -1
                    num = 0
                }
            default:
                break
            }
        }
        if numRightPos >= 0 {
            thisLineNumbers.append((left:numLeftPos, right:numRightPos, value:num))
            numLeftPos = -1
            numRightPos = -1
            num = 0
        }


        // Now analyse the found numbers for adjacency to symbols
        for numble in prevLineNumbers {
            for (symbolPos,_) in thisLineGears {
                if numble.left-1 <= symbolPos && symbolPos <= numble.right+1 {
                    thisLineGears.append(element: numble.value, toValueOfKey: symbolPos)
                }
            }

        }
        prevLineNumbers = []

        for numble in thisLineNumbers {
            for (symbolPos,_) in prevLineGears {
                if numble.left-1 <= symbolPos && symbolPos <= numble.right+1 {
                    prevLineGears.append(element: numble.value, toValueOfKey: symbolPos)
                }
            }
            if numble.left > 0 && (thisLineGears.index(forKey: numble.left-1) != nil) {
                thisLineGears.append(element: numble.value, toValueOfKey: numble.left-1)
            }
            if thisLineGears.index(forKey: numble.right+1) != nil {
                thisLineGears.append(element: numble.value, toValueOfKey: numble.right+1)
            }

            prevLineNumbers.append(numble)
        }

        for (_, val) in prevLineGears {
            if val.count == 2 {
                let power = val[0] * val[1];
                sum += power
            }
        }

        prevLineGears = thisLineGears
    }

    for (_, val) in thisLineGears {
        if val.count == 2 {
            let power = val[0] * val[1];
            sum += power
        }
    }


    return sum
}

func runMeasured(_ operation: (String) -> Int, with operand: String) -> Void
{
    let startTime = DispatchTime.now()
    let solution = operation(operand)
    let endTime = DispatchTime.now()
    print(solution)

    let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds

    print("   (Took \(Double(elapsedTime) / 1_000_000_000)s)")
}


runMeasured(part1, with: schematic!)
runMeasured(part2, with: schematic!)

//: [Next](@next)
