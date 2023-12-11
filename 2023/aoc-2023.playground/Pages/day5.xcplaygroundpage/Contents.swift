//: [Previous](@previous)

import Foundation

let realAlmanach: String?
if let input = Bundle.main.url(forResource: "day5_input", withExtension: "txt") {
    realAlmanach = try String(contentsOf: input)
    if realAlmanach == nil {
        exit(EXIT_FAILURE)
    }
}
else {
    exit(EXIT_FAILURE)
}

let myAlmanachTest = """
seeds: 79 14 55 13

seed-to-soil map:
14 10 2
24 18 10
18 28 6

soil-to-fertilizer map:
3 0 3
1 5 2
10 12 2
12 14 2
14 17 2
17 19 3
27 22 2
21 27 2
33 29 2
29 31 4
"""


let almanachTest = """
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
"""

let almanach = realAlmanach!

struct MapRange
{
    var src: Int
    var dest: Int
    var range: Int
}

var seeds: [Int] = []
var seedToSoilMap: [MapRange] = []
var soilToFertilizerMap: [MapRange] = []
var fertilizerToWaterMap : [MapRange] = []
var waterToLightMap: [MapRange] = []
var lightToTemperatureMap: [MapRange] = []
var temperatureToHumidityMap: [MapRange] = []
var humidityToLocationMap: [MapRange] = []

enum MapTypes: String {
    case seed_to_soil = "seed-to-soil"
    case soil_to_fertilizer = "soil-to-fertilizer"
    case fertilizer_to_water = "fertilizer-to-water"
    case water_to_light = "water-to-light"
    case light_to_temperature = "light-to-temperature"
    case temperature_to_humidity = "temperature-to-humidity"
    case humidity_to_location = "humidity-to-location"

    func insert(mapRange: MapRange) {
        switch self {
        case .seed_to_soil:
            insertSortedBySource(map: &seedToSoilMap, range: mapRange)
        case .soil_to_fertilizer:
            insertSortedBySource(map: &soilToFertilizerMap, range: mapRange)
        case .fertilizer_to_water:
            insertSortedBySource(map: &fertilizerToWaterMap, range: mapRange)
        case .water_to_light:
            insertSortedBySource(map: &waterToLightMap, range: mapRange)
        case .light_to_temperature:
            insertSortedBySource(map: &lightToTemperatureMap, range: mapRange)
        case .temperature_to_humidity:
            insertSortedBySource(map: &temperatureToHumidityMap, range: mapRange)
        case .humidity_to_location:
            insertSortedBySource(map: &humidityToLocationMap, range: mapRange)
        }
    }
}


func insertSortedBySource(map: inout [MapRange], range: MapRange) {
    if let idx = map.firstIndex(where: {$0.src > range.src}) {
        map.insert(range, at: idx)
    }
    else {
        map.append(range)
    }
}

func insertSortedByDest(map: inout [MapRange], range: MapRange) {
    if let idx = map.firstIndex(where: {$0.dest > range.dest}) {
        map.insert(range, at: idx)
    }
    else {
        map.append(range)
    }
}


func parseAlmanach() -> Int
{
    var activeMapType: MapTypes = .seed_to_soil

    for line in almanach.components(separatedBy: .newlines) {
        if let idx = line.firstIndex(of: ":") {
            if line.hasPrefix("seeds:") {
                for seed in line.substring(from: line.index(after: idx)).components(separatedBy: " ") {
                    if let s = Int(seed) {
                        seeds.append(s)
                    }
                }
            }
            else if line.hasPrefix(MapTypes.seed_to_soil.rawValue) {
                activeMapType = .seed_to_soil
            }
            else if line.hasPrefix(MapTypes.soil_to_fertilizer.rawValue) {
                activeMapType = .soil_to_fertilizer
            }
            else if line.hasPrefix(MapTypes.fertilizer_to_water.rawValue) {
                activeMapType = .fertilizer_to_water
            }
            else if line.hasPrefix(MapTypes.water_to_light.rawValue) {
                activeMapType = .water_to_light
            }
            else if line.hasPrefix(MapTypes.light_to_temperature.rawValue) {
                activeMapType = .light_to_temperature
            }
            else if line.hasPrefix(MapTypes.temperature_to_humidity.rawValue) {
                activeMapType = .temperature_to_humidity
            }
            else if line.hasPrefix(MapTypes.humidity_to_location.rawValue) {
                activeMapType = .humidity_to_location
            }
            else {
                assertionFailure("I don't understand this unexpected line: \(line)")
            }
        }
        else if line.isEmpty {

        }
        else {
            let values = line.components(separatedBy: " ")
            if values.count != 3 {
                assertionFailure("This line doesn't have the required three parts: \(line)")
            }

            if let dest = Int(values[0]) , let src = Int(values[1]), let range = Int(values[2])  {
                activeMapType.insert(mapRange: MapRange(src: src, dest: dest, range: range))
            }
            else {
                assertionFailure("This line doesn't have three Integers: \(line)")
            }

        }
    }

    return 0
}


extension MapRange: CustomStringConvertible
{
    var description: String {
        return "\(src) _\(range) - \(dest)"
    }
}

func printMap(map: [MapRange])
{
    for range in map {
        print("\(range)")
    }
    print("")
}

func findDestination(source: Int, map: [MapRange]) -> Int
{
    for range in map {
        if source >= range.src {
            let offset = source - range.src
            if offset < range.range {
                return range.dest + offset
            }
        }
    }
    return source
}




func part1() -> Int
{
    var minLocation = 0
    var locations: [Int] = []

    for seed in seeds {
        let soil = findDestination(source: seed, map: seedToSoilMap)
        let fertilizer = findDestination(source: soil, map: soilToFertilizerMap)
        let water = findDestination(source: fertilizer, map: fertilizerToWaterMap)
        let light = findDestination(source: water, map: waterToLightMap)
        let temperature = findDestination(source: light, map: lightToTemperatureMap)
        let humidity = findDestination(source: temperature, map: temperatureToHumidityMap)
        let location = findDestination(source: humidity, map: humidityToLocationMap)

//        print("Seed \(seed), soil \(soil), fertilizer \(fertilizer), water \(water), light \(light), temperature \(temperature), humidity \(humidity), location \(location)")
        locations.append(location)
    }

    minLocation = locations.min()!
    return minLocation
}


func foldMaps(dest: [MapRange], into sourceMap: [MapRange], withUnmapped: Bool = true) -> [MapRange]
{
    var seedToLocationMap: [MapRange] = []
    func insertToLocationMap(_ range: MapRange)
    {
        if (range.src != range.dest) {
            insertSortedByDest(map: &seedToLocationMap, range: range)
        }
        else {
//            print("Skipping new source range \(range) because it maps directly.")
        }
    }


    var destMap = dest
    for source in sourceMap {
        /*
            Find all ranges in the destination map that overlap with the range that this source range maps to
            source:     |======|
            dest:       |------|
                      |----|
                             |----|
                          |--|
                    |----------------|
         */
        var coveredSourceRange = 0

        while var idx = destMap.firstIndex(where: {$0.src < (source.dest + source.range) && ($0.src + $0.range) > source.dest}) {
            // Found a destination range that is touched by the source range
            var dest = destMap.remove(at: idx)

            if dest.src < source.dest {
                /* The destination range starts before the mapped source range.
                         source:     |======|
                         dest:     |---|
                                |--------------|
                      This means that we need to add a new range into the destination map that
                      covers the first part of the destination range before the mapped
                      source range starts.
                    */
                var src = dest.src
                var rng = source.dest - dest.src
                var dst = dest.dest
                let dr = MapRange(src:src, dest:dst, range:rng)
                destMap.insert(dr, at: idx)
                destMap.formIndex(after: &idx)

                // We covered the first part of the destination range, so reduce it to the rest.
                dest.src = dest.src + rng
                dest.dest = dest.dest + rng
                dest.range = dest.range - rng
            }

            if dest.src == source.dest {
                /* The destination range starts at the same position as the mapped source range
                        source:   |======|
                        dest:     |------|
                                  |--|
                                  |-----------|
                     Now we need to check which part of the mapped source range is covered and convert that.
                   */

                var src = source.src
                var rng = min(source.range, dest.range)
                var dst = dest.dest
                insertToLocationMap(MapRange(src:src, dest:dst, range:rng))

                coveredSourceRange += rng

                // We covered some part of the source, so reduce the destination to the rest.
                dest.src = dest.src + rng
                dest.dest = dest.dest + rng
                dest.range = dest.range - rng
            }

            if dest.src > source.dest  && dest.range > 0 && dest.src < (source.dest + source.range) {
                /* The destination range starts after the start of the mapped source range and has a rest left.
                       source:   |======|
                       dest:        |---|
                                   |--|
                                      |------|
                     First we need to create a new source range from any uncovered part and fold the destination into that.
                     Now we need to check which part of the mapped source range is covered and convert that.
                   */

                if source.dest + coveredSourceRange < dest.src {
                    var src = source.src + coveredSourceRange
                    var rng = dest.src - source.dest
                    var dst = source.dest + coveredSourceRange
                    insertToLocationMap(MapRange(src:src, dest:dst, range:rng))
                    coveredSourceRange += rng
                }

                var src = source.src + (dest.src - source.dest)
                var rng = if (dest.src + dest.range) <= (source.dest + source.range) {  // The destination range ends before or with the source range
                             dest.range
                          }
                          else {                                                      // The destination range ends after the source range.
                              (source.dest + source.range) - dest.src                  // Only take up to sources end for the new range
                          }
                var dst = dest.dest
                insertToLocationMap(MapRange(src:src, dest:dst, range:rng))

                coveredSourceRange += rng

                // We covered some part of the source, so reduce the destination to the rest.
                dest.src = dest.src + rng
                dest.dest = dest.dest + rng
                dest.range = dest.range - rng
            }

            // By now we should have covered all overlapping cases.
            if dest.range > 0 {
                /* There is still destination range left after the mapped source:
                        source:   |======|
                        dest:            |------|
                      We need to save this for later, so put it back into the destination map for later overlaps.
                  */
                destMap.insert(dest, at: idx)
            }
        }

        // If there is still source range left, that was not mapped to a range in the destination map,
        // create a new source range with the left over part.
        if coveredSourceRange < source.range {
            var rng = source.range - coveredSourceRange
            var src = source.src + coveredSourceRange
            var dst = source.dest + coveredSourceRange
            insertToLocationMap(MapRange(src:src, dest:dst, range:rng))

        }
    }

    if (withUnmapped) {
        // Now fold in the left over destination mappings
        for dest in destMap {
            insertToLocationMap(MapRange(src: dest.src, dest: dest.dest, range: dest.range))
        }
    }

    return seedToLocationMap
}


func part2() -> Int
{
    var minLocation = 0
    var locations: [Int] = []

    if seeds.count % 2 != 0 {
        assertionFailure("The seeds list must have an even number of entries")
    }

    var seedToLocationMap = seedToSoilMap.sorted(by: {$0.dest < $1.dest})

    seedToLocationMap = foldMaps(dest: soilToFertilizerMap, into: seedToLocationMap)
    seedToLocationMap = foldMaps(dest: fertilizerToWaterMap, into: seedToLocationMap)
    seedToLocationMap = foldMaps(dest: waterToLightMap, into: seedToLocationMap)
    seedToLocationMap = foldMaps(dest: lightToTemperatureMap, into: seedToLocationMap)
    seedToLocationMap = foldMaps(dest: temperatureToHumidityMap, into: seedToLocationMap)
    seedToLocationMap = foldMaps(dest: humidityToLocationMap, into: seedToLocationMap)

    var seedRanges: [MapRange] = []
    var i:Int = 0
    while i < seeds.count {
        seedRanges.append(MapRange(src: seeds[i], dest: seeds[i], range: seeds[i+1]))
        i += 2
    }

    print("Seeds: \(seeds)")
    var seedLocations = foldMaps(dest: seedToLocationMap, into: seedRanges, withUnmapped: false)

//    print("\n===  Seed locations  ==========")
//    printMap(map: seedLocations.sorted(by: {$0.src < $1.src}))
    for locRange in seedLocations {
        locations.append(locRange.dest)
    }

    minLocation = locations.min()!
    return minLocation
}



func runMeasured(_ operation: () -> Int, with operand: String) -> Void
{
    let startTime = DispatchTime.now()
    let solution = operation()
    let endTime = DispatchTime.now()
    print("Solution: \(solution)")

    let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds

    print("                   (Took \(Double(elapsedTime) / 1_000_000_000)s)")
}


runMeasured(parseAlmanach, with: almanach)
//runMeasured(part1, with: almanach)
runMeasured(part2, with: almanach)


//: [Next](@next)
