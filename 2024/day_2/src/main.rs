use std::fs::read_to_string;

fn main() {
    let _test_input = "7 6 4 2 1
                       1 2 7 8 9
                       9 7 6 2 1
                       1 3 2 4 5
                       8 6 4 4 1
                       1 3 6 7 9";

    let _test_input2 = "7 6 4 2 1
                        1 2 7 5 8
                        9 7 6 2 3
                        1 4 2 3 5
                        8 6 4 4 1
                        1 3 6 7 9
                        47 50 52 55 57 55
                        20 21 24 22 26 27";

    let _test_input3 = "48 46 47 49 51 54 56
                        1 1 2 3 4 5
                        1 2 3 4 5 5
                        5 1 2 3 4 5
                        1 4 3 2 1
                        1 6 7 8 9
                        1 2 3 4 3
                        9 8 7 6 7
                        7 10 8 10 11
                        29 28 27 25 26 25 22 20";

    let real_input = read_to_string("input.txt").unwrap();

    let input = _test_input3;
    //let input = &real_input[..];

    println!("Part 1");
    part1(input);

    println!("\nPart 2");
    part2(input);
}

fn part1(input: &str) {
    let mut safe_reports = 0;

    for line in input.lines() {
        let mut prev = -1;
        let mut dir = 0;

        for number in line.split_whitespace() {
            let num: i32 = number.parse().unwrap();
            if prev >= 0 {
                let diff = num - prev;

                // If we don't have a direction yet, set it to postivie (increasing) or negative (descreasing)
                if dir == 0 {
                    dir = diff;
                }

                // If the difference is positive, the report is increasing, i.e. positive direction
                if diff > 0 {
                    if dir < 0 {
                        // We changed direction.
                        dir = 0;
                        break;
                    }

                    if diff > 3 {
                        // This step is too big.
                        dir = 0;
                        break;
                    }

                // If the difference is negative, the report is decreasing, i.e. direction -1
                } else if diff < 0 {
                    if dir > 0 {
                        // We changed direction.
                        dir = 0;
                        break;
                    }
                    if diff < -3 {
                        // This step is too big.
                        dir = 0;
                        break;
                    }
                }
                // Otherwise the difference is 0. This is not a safe report. Skip to next line.
                else {
                    dir = 0;
                    break;
                }
            }
            prev = num;
        }

        if dir != 0 {
            safe_reports += 1;
        }
    }

    println!("Safe reports:  {}", safe_reports);
}

fn part2(input: &str) {
    let mut safe_reports = 0;
    let mut safed_reports = 0;

    for line in input.lines() {
        let mut prev = -1;
        let mut prev_prev = -1;
        let mut dir = 0;
        let mut removable_levels = 1;
        let mut removed_num = 0;
        let mut dampener: Option<(i32, i32, i32)> = None;

        // let mut numbers: Vec<i32> = Vec::new();
        // for number in line.split_whitespace() {
        //     // Parse numbers from string into a Vector
        //     let num: i32 = number.parse().unwrap();
        //     numbers.push(num);
        // }

        for number in line.split_whitespace() {
            let num: i32 = number.parse().unwrap();
            if prev >= 0 {
                let mut diff = num - prev;

                // If we don't have a direction yet, set it to postivie (increasing) or negative (descreasing)
                if dir == 0 {
                    dir = diff;
                }

                // If we have an active dampener, check if we can safe this report by removing a level.
                if dampener.is_some() {
                    let mut removed_pos = 0;
                    if !check_dampener(dampener, num, &mut removed_num, &mut removed_pos) {
                        // We can't safe the report by removing a level. Continue with the next one.
                        removable_levels -= 1;
                        break;
                    }
                    // Level can be removed to safe the report.
                    // Set the correct previous level and continue with the this one.
                    if removed_pos == 2 {
                        prev = dampener.unwrap().1;
                    } else {
                        prev = dampener.unwrap().2;
                    }
                    diff = num - prev;
                    dampener = None;
                }

                // If the difference is positive, the report is increasing, i.e. positive direction
                if diff > 0 {
                    if dir < 0 {
                        // We changed direction.
                        removable_levels -= 1;
                        if removable_levels < 0 {
                            // We can't remove any more levels. This is not a safe report. Skip to next line.
                            break;
                        } else {
                            // Create a dampener with the last three numbers and continue with the next one.
                            dampener = Some((prev_prev, prev, num));
                            continue;
                        }
                    }

                    if diff > 3 {
                        // This step is too big.
                        removable_levels -= 1;
                        if removable_levels < 0 {
                            // We can't remove any more levels. This is not a safe report. Skip to next line.
                            break;
                        } else {
                            // Ignore this level and continue with the next one
                            removed_num = num;
                            continue;
                        }
                    }

                // If the difference is negative, the report is decreasing, i.e. direction -1
                } else if diff < 0 {
                    if dir > 0 {
                        // We changed direction.
                        removable_levels -= 1;
                        if removable_levels < 0 {
                            // We can't remove any more levels. This is not a safe report. Skip to next line.
                            break;
                        } else {
                            // Create a dampener with the last three numbers and continue with the next one.
                            dampener = Some((prev_prev, prev, num));
                            continue;
                        }
                    }

                    if diff < -3 {
                        // This step is too big.
                        removable_levels -= 1;
                        if removable_levels < 0 {
                            // We can't remove any more levels. This is not a safe report. Skip to next line.
                            break;
                        } else {
                            // Ignore this level and continue with the next one
                            removed_num = num;
                            continue;
                        }
                    }
                }
                // Otherwise the difference is 0. Try to safe the report by leaving the current number out.
                else {
                    removable_levels -= 1;
                    if removable_levels < 0 {
                        break;
                    } else {
                        removed_num = num;
                        continue;
                    }
                }
            }
            prev_prev = prev;
            prev = num;
        }

        // If we have a pending dampener, because we reached the end of the line before checking,
        // simply safe this report by leaving out the last level.
        if dampener.is_some() {
            removed_num = dampener.unwrap().2;
        }

        if removable_levels == 0 {
            println!(
                "The line was made safe by removing number {}: {}",
                removed_num, line
            );
            safed_reports += 1;
        } else if removable_levels == -1 {
            println!(
                "The line could not be safed, after removing {}: {}",
                removed_num, line
            );
        } else if removable_levels == 1 {
            safe_reports += 1;
        }
    }

    println!("Safe reports:  {}", safe_reports);
    println!("Safed reports: {}", safed_reports);
    println!("Sum reports:   {}", safe_reports + safed_reports);
}

fn check_dampener(
    dampener: Option<(i32, i32, i32)>,
    num: i32,
    removed_num: &mut i32,
    removed_pos: &mut i32,
) -> bool {
    // Check each triple from the dampener and the current number
    // if they create a safe subreport.

    println!("Check dampener {:?}", dampener);

    let (p3, p2, p1) = dampener.unwrap();

    let d1 = p2 - p3;
    let d2 = num - p2;
    if d1 > 0 && d2 > 0 {
        if d1 < 4 && d2 < 4 {
            *removed_num = p1;
            *removed_pos = 2;
            return true;
        }
    }

    let d1 = p1 - p2;
    let d2 = num - p1;
    if d1 > 0 && d2 > 0 {
        if d1 < 4 && d2 < 4 {
            *removed_num = p3;
            *removed_pos = 0;
            return true;
        }
    }

    let d1 = p1 - p3;
    let d2 = num - p1;
    if d1 > 0 && d2 > 0 {
        if d1 < 4 && d2 < 4 {
            *removed_num = p2;
            *removed_pos = 1;
            return true;
        }
    }

    return false;
}
