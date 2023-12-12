//: [Previous](@previous)

import Foundation

var realHands = readInput(filename: "day7_input")

var testHands = """
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"""


enum CardType: Comparable
{
    case joker
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king
    case ace

    static func from(_ face: Character, withJoker: Bool = false) -> CardType
    {
        switch face {
        case "2":
            return .two
        case "3":
            return .three
        case "4":
            return .four
        case "5":
            return .five
        case "6":
            return .six
        case "7":
            return .seven
        case "8":
            return .eight
        case "9":
            return .nine
        case "T":
            return .ten
        case "J":
            return withJoker ? .joker : .jack
        case "Q":
            return .queen
        case "K":
            return .king
        case "A":
            return .ace
        default:
            assertionFailure("Unkown card symbol '\(face)'")
            return .two
        }
    }
}

enum HandType: Comparable
{
    case undetermined
    case highCard
    case onePair
    case twoPair
    case threeOfAKind
    case fullHouse
    case fourOfAKind
    case fiveOfAKind
}


class Hand : CustomStringConvertible, Comparable
{
    let hand: String
    let bid: Int
    let cards: [CardType]
    let type: HandType
    let withJoker: Bool

    static var timeForDeterminingType: UInt64 = 0
    static var timeForDeterminingCards: UInt64 = 0
    static var timeSpentInConstructor: UInt64 = 0

    init(hand: String, bid: Int, withJoker: Bool = false) {
        let startTime = DispatchTime.now()
        self.hand = hand
        self.bid = bid
        self.withJoker = withJoker

        self.type = Hand.determineType(hand: hand, withJoker: withJoker)
        var faces: [CardType] = []
        for face in hand {
            faces.append(CardType.from(face, withJoker: withJoker))
        }
        self.cards = faces
        let endTime = DispatchTime.now()

        Hand.timeSpentInConstructor += (endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
    }

    var description: String {
        return "\(hand) \(bid) is \(type)"
    }

    static func <(lhs:Hand, rhs:Hand) -> Bool
    {
        if lhs.type != rhs.type {
            return lhs.type < rhs.type
        }
        for i in 0...lhs.cards.count {
            if lhs.cards[i] != rhs.cards[i] {
                return lhs.cards[i] < rhs.cards[i]
            }
        }
        return false // Are equal
    }

    static func ==(lhs: Hand, rhs: Hand) -> Bool
    {
        if lhs.type != rhs.type {
            return false
        }
        for i in 0...lhs.cards.count {
            if lhs.cards[i] != rhs.cards[i] {
                return false
            }
        }
        return true
    }



    private static func determineType(hand: String, withJoker: Bool = false) -> HandType
    {
        let cards = hand.sorted()

        var stretches: [Int] = []
        var prev = 0
        var stretch = 1
        var js = (cards[0] == "J") ? 1 : 0
        for curr in 1..<cards.count {
            if cards[curr] == cards[prev] {
                stretch += 1
            }
            else {
                stretches.append(stretch)
                stretch = 1
                prev = curr
            }
            if cards[curr] == "J" {
                js += 1
            }
        }
        stretches.append(stretch)
        stretches.sort(by: >)

        switch stretches.count {
        case 1:
            return .fiveOfAKind
        case 2:
            if withJoker && js > 0 {
                return .fiveOfAKind
            }
            if stretches.first == 4 {
                return .fourOfAKind
            }
            else if stretches.first == 3 {
                return .fullHouse
            }
            else {
                assertionFailure("Two stretches and the first is not 4 or 3 is impossible.  Hand '\(hand)', stretches: \(stretches)")
            }
        case 3:
            if stretches.first == 3 {
                if withJoker && js > 0 {
                    return .fourOfAKind
                }
                return .threeOfAKind
            }
            else if stretches.first == 2 {
                if withJoker && js > 0 {
                    if js == 2 {
                        return .fourOfAKind
                    }
                    else {
                        return .fullHouse
                    }
                }
                return .twoPair
            }
            else {
                assertionFailure("Three stretches and the first is not 3 or 2 is impossible. Hand '\(hand)', stretches: \(stretches)")
            }
        case 4:
            if withJoker && js > 0 {
                return .threeOfAKind
            }
            return .onePair
        default:
            if withJoker && js > 0 {
                return .onePair
            }
            return .highCard
        }
        return .highCard
    }
}


var timeForNewHand: UInt64 = 0
var timeForAppendingHand: UInt64 = 0

func parseHands(_ str: String, withJoker: Bool = false) -> [Hand]
{
    var hands: [Hand] = []

    var lines = splitIntoLines(str)
    hands.reserveCapacity(lines.count + 10)

    print("Hands array capacity: \(hands.capacity)")

    for line in lines {
        let parts = line.components(separatedBy: " ")
        let startTime = DispatchTime.now()
        let hand = Hand(hand: parts[0], bid: Int(parts[1])!, withJoker: withJoker)
        let midTime = DispatchTime.now()
        hands.append(hand)
        let endTime = DispatchTime.now()

        timeForNewHand += (midTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
        timeForAppendingHand += (endTime.uptimeNanoseconds - midTime.uptimeNanoseconds)

    }

    return hands
}



func part1(handsStr: String) -> Int
{
    var hands = parseHands(handsStr)
    hands.sort()

    var sum = 0
    for (rank, hand) in hands.enumerated() {
        sum += (rank + 1) * hand.bid
    }

    return sum
}

func part2(handsStr: String) -> Int
{
    var hands = parseHands(handsStr, withJoker: true)
    hands.sort()

    var sum = 0
    for (rank, hand) in hands.enumerated() {
        sum += (rank + 1) * hand.bid
    }

    return sum
}

var hands = realHands

runMeasured(part1, with: hands)
print("                   (Time spent in constructor:  \(Double(Hand.timeSpentInConstructor)  / 1_000_000_000)s)")
print("                   (Time for new hand: \(Double(timeForNewHand) / 1_000_000_000)s)")
print("                   (Time for appending hand: \(Double(timeForAppendingHand) / 1_000_000_000)s)")

Hand.timeForDeterminingCards = 0
Hand.timeForDeterminingType = 0
Hand.timeSpentInConstructor = 0
timeForNewHand = 0
timeForAppendingHand = 0

runMeasured(part2, with: hands)
print("                   (Time spent in constructor:  \(Double(Hand.timeSpentInConstructor)  / 1_000_000_000)s)")
print("                   (Time for new hand: \(Double(timeForNewHand) / 1_000_000_000)s)")
print("                   (Time for appending hand: \(Double(timeForAppendingHand) / 1_000_000_000)s)")

//: [Next](@next)
