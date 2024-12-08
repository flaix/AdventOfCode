use std::fs::read_to_string;

fn main() {
    // 2 safe reports
    // 2 reports can be safed
    let _test_input = "7 6 4 2 1
                       1 2 7 8 9
                       9 7 6 2 1
                       1 3 2 4 5
                       8 6 4 4 1
                       1 3 6 7 9";

    // 2 safe reports
    // 6 reports can be safed
    let _test_input2 = "7 6 4 2 1
                        1 2 7 5 8
                        9 7 6 2 3
                        1 4 2 3 5
                        8 6 4 4 1
                        1 3 6 7 9
                        47 50 52 55 57 55
                        20 21 24 22 26 27";

    // 10 reports can be safed
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

    // let input = _test_input3;
    let input = &real_input[..];

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

                // If we don't have a direction yet, set it to positive (increasing) or negative (descreasing)
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
        let mut pos = 0;
        let mut dir = 0;
        let mut prev = -1;
        let mut removable_levels = 1;
        let mut removed_num = -1;
        let mut violation_flagged = false;
        let mut numbers: Vec<i32> = Vec::new();

        for number in line.split_whitespace() {
            let num: i32 = number.parse().unwrap();
            numbers.push(num);

            // Fill in the first three numbers in order to get to a full first sliding window.
            if pos < 3 {
                pos += 1;
                continue;
            }

            // If we don't have a direction yet, determine it by testing the first window.
            if dir == 0 {
                let window = &numbers[..4];
                let mut removed_pos = -1;
                dir = check_first_window(window, &mut removed_num, &mut removed_pos);
                if dir == 0 {
                    // No direction could be determined. This report cannot be safed.
                    removable_levels = -1;
                    break;
                }

                prev = window[2];
                if removed_pos >= 0 {
                    // A level was removed, adjust prev accordingly.
                    removable_levels -= 1;
                    if removed_pos == 2 {
                        prev = window[1];
                    }
                }
            }

            // If we have a violation check pending, check the window if the report can be safed.
            if violation_flagged {
                removable_levels -= 1;

                let mut removed_pos = 0;
                if !check_window(
                    &numbers[pos - 3..pos + 1],
                    dir,
                    &mut removed_num,
                    &mut removed_pos,
                ) {
                    // We can't safe the report by removing a level. Continue with the next one.
                    removable_levels -= 1;
                    break;
                }
                // Level can be removed to safe the report.
                // Set the correct previous level and continue with the this one.
                violation_flagged = false;
                prev = numbers[pos];
                pos += 1;
                continue;
            }

            // Otherwise continue by checking each new level one by one against the previous one.
            let diff = num - prev;

            // If the difference is positive, the report is increasing, i.e. positive direction
            if diff > 0 {
                if dir < 0 || diff > 3 {
                    // We changed direction or this step is too big.
                    // Flag a violation and continue to the next level, to fill the check window.
                    if removable_levels < 1 {
                        // We can't remove any more levels. This is not a safe report. Skip to next line.
                        removable_levels -= 1;
                        break;
                    } else {
                        violation_flagged = true;
                        pos += 1;
                        continue;
                    }
                }

            // If the difference is negative, the report is decreasing, i.e. direction -1
            } else if diff < 0 {
                if dir > 0 || diff < -3 {
                    // We changed direction or this step is too big.
                    // Flag a violation and continue to the next level, to fill the check window.
                    if removable_levels < 1 {
                        // We can't remove any more levels. This is not a safe report. Skip to next line.
                        removable_levels -= 1;
                        break;
                    } else {
                        violation_flagged = true;
                        pos += 1;
                        continue;
                    }
                }

            // Otherwise the difference is 0. Try to safe the report by leaving the current number out.
            } else {
                removable_levels -= 1;
                if removable_levels < 0 {
                    break;
                } else {
                    removed_num = num;
                    pos += 1;
                    continue;
                }
            }

            prev = num;
            pos += 1;
        }

        // If we have a flagged violation, because we reached the end of the line before checking,
        // simply safe this report by leaving out the last level.
        if violation_flagged && removable_levels > 0 {
            removed_num = numbers[numbers.len() - 1];
            removable_levels -= 1;
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

fn check_first_window(window: &[i32], removed_num: &mut i32, removed_pos: &mut i32) -> i32 {
    // Check if the first three numbers in the window are safe with the fourth number.
    // If they are, return  the direction. If they are not, return 0, i.e. no direction.

    println!("Checking first window {:?}", window);

    let d1 = window[1] - window[0];
    let d2 = window[2] - window[1];

    // If the differences are positive, the report is increasing, i.e. positive direction
    // All differences must be less that 4 for the whole window to be safe.
    if d1 > 0 && d2 > 0 {
        if d1 < 4 && d2 < 4 {
            println!("First window is safe, determined direction increase");
            return 1;
        }
    }

    // If the differences are negative, the report is decreasing, i.e. direction -1
    // All differences must be less that -4 for the whole window to be safe.
    if d1 < 0 && d2 < 0 {
        if d1 > -4 && d2 > -4 {
            println!("First window is safe, determined direction decrease");
            return -1;
        }
    }

    let mut dir = 0;

    // Otherwise check if the window can be made safe by removing a number.
    // If it can, return the direction. If it can't, return 0.

    // Leave out the first level  i.e. window[0]
    let d1 = window[2] - window[1];
    let d2 = window[3] - window[2];
    if d1.abs() < 4 && d2.abs() < 4 {
        if d1 > 0 && d2 > 0 {
            dir = 1;
        } else if d1 < 0 && d2 < 0 {
            dir = -1;
        }
    }
    if dir != 0 {
        *removed_pos = 0;
        *removed_num = window[0];
        return dir;
    }

    // Leave out the second level  i.e. window[1]
    let d1 = window[2] - window[0];
    let d2 = window[3] - window[2];
    if d1.abs() < 4 && d2.abs() < 4 {
        if d1 > 0 && d2 > 0 {
            dir = 1;
        } else if d1 < 0 && d2 < 0 {
            dir = -1;
        }
    }
    if dir != 0 {
        *removed_pos = 1;
        *removed_num = window[1];
        return dir;
    }

    // Leave out the third level  i.e. window[2]
    let d1 = window[1] - window[0];
    let d2 = window[3] - window[1];
    if d1.abs() < 4 && d2.abs() < 4 {
        if d1 > 0 && d2 > 0 {
            dir = 1;
        } else if d1 < 0 && d2 < 0 {
            dir = -1;
        }
    }
    if dir != 0 {
        *removed_pos = 2;
        *removed_num = window[2];
        return dir;
    }

    // If this did not work, we cannot safe the report. Return no direction (0) to indicate that the first window is not safe.
    *removed_pos = -1;
    *removed_num = -1;
    return 0;
}

fn check_window(window: &[i32], dir: i32, removed_num: &mut i32, removed_pos: &mut i32) -> bool {
    // One number needs to be removed. Check each triple from the window, if they create a safe window
    // for the current direction.

    println!("Check window {:?}", window);

    // Leave out the level creating the violation, i.e. window[2]
    let d1 = window[1] - window[0];
    let d2 = window[3] - window[1];
    if d1.signum() == dir && d2.signum() == dir {
        if d1.abs() < 4 && d2.abs() < 4 {
            *removed_pos = 2;
            *removed_num = window[2];
            return true;
        }
    }

    // Leave out the level before the violation, i.e. window[1]
    let d1 = window[2] - window[0];
    let d2 = window[3] - window[2];
    if d1.signum() == dir && d2.signum() == dir {
        if d1.abs() < 4 && d2.abs() < 4 {
            *removed_pos = 1;
            *removed_num = window[1];
            return true;
        }
    }

    *removed_pos = -1;
    *removed_num = -1;
    return false;
}
