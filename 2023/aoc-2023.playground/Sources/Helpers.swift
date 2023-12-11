import Foundation

public func readInput(filename: String) -> String
{
    if let input = Bundle.main.url(forResource: filename, withExtension: "txt") {
        do {
            let puzzle = try String(contentsOf: input)
            return puzzle
        }
        catch {
            preconditionFailure("Unable to convert input to String")
        }
    }
    else {
        preconditionFailure("Could not read input from file \(filename).txt")
    }
}


public func splitIntoLines(_ string: String) -> [String.SubSequence]
{
    return string.split(separator: "\n")
}


public func runMeasured(_ operation: (_:String) -> Int, with operand: String) -> Void
{
    let startTime = DispatchTime.now()
    let solution = operation(operand)
    let endTime = DispatchTime.now()
    print("Solution: \(solution)")

    let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds

    print("                   (Took \(Double(elapsedTime) / 1_000_000_000)s)")
}

public func runMeasured(_ operation: () -> Int) -> Void
{
    let startTime = DispatchTime.now()
    let solution = operation()
    let endTime = DispatchTime.now()
    print("Solution: \(solution)")

    let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds

    print("                   (Took \(Double(elapsedTime) / 1_000_000_000)s)")
}
