//: [Previous](@previous)

import Foundation

let realCards: String?
if let input = Bundle.main.url(forResource: "day4_input", withExtension: "txt") {
    realCards = try String(contentsOf: input)
    if realCards == nil {
        exit(EXIT_FAILURE)
    }
}
else {
    exit(EXIT_FAILURE)
}


let cardsTest = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"""

let cards = realCards!


func part1(cards: String) -> Int
{
    let reD = /(\d+)/
    var sum = 0
    var winningNumbers: [Int]

    for line in cards.split(separator: "\n") {
        winningNumbers = []
        var points = 0
        let drawNums = line.split(separator: "|")

        var matches = drawNums[0].matches(of: reD)
        matches.removeFirst()
        for match in matches {
            winningNumbers.append(Int(match.0)!)
        }

        matches = drawNums[1].matches(of: reD)
        for match in matches {
            let myNum = Int(match.0)!
            if winningNumbers.contains(myNum) {
                if points == 0 {
                    points = 1
                }
                else {
                    points *= 2
                }
            }
        }
        sum += points
    }

    return sum
}

func part2(cards: String) -> Int
{
    let reD = /(\d+)/
    var sum = 0
    var winningNumbers: [Int]
    var scratchcards: [Int:Int] = [:]

    func addCard(_ id:Int, times: Int = 1) -> Void
    {
//        if let idx = scratchcards.index(forKey: id) {
//            scratchcards.updateValue(scratchcards[idx].value + 1, forKey: id)
//        }
//        else {
//            scratchcards[id] = 1
//        }
        scratchcards[id, default: 0] += times
    }

    var card: Int = 0

    for line in cards.split(separator: "\n") {
        winningNumbers = []
        var points = 0
        let drawNums = line.split(separator: "|")

        var matches = drawNums[0].matches(of: reD)
        card = Int(matches.removeFirst().0)!
        for match in matches {
            winningNumbers.append(Int(match.0)!)
        }

        matches = drawNums[1].matches(of: reD)
        for match in matches {
            let myNum = Int(match.0)!
            if winningNumbers.contains(myNum) {
                points += 1
            }
        }

        addCard(card)
        for won in 0..<points {
            addCard(card + won + 1, times: scratchcards[card]!)
        }
    }

    return scratchcards.reduce(0) { sum, item in
        if item.key <= card {
            return sum + item.value
        }
        return sum
    }
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


runMeasured(part1, with: cards)
runMeasured(part2, with: cards)




//: [Next](@next)
