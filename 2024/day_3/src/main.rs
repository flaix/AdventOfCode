use regex::Regex;
use std::fs::read_to_string;

fn main() {
    let _sample_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    let _sample_input2 =
        "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    let real_input = read_to_string("input.txt").unwrap();

    //let input = _sample_input2;
    let input = &real_input[..];

    println!("Part 1");
    part1(input);

    println!("\nPart 2");
    part2(input);
}

fn part1(input: &str) {
    let mut sum = 0;

    let re = Regex::new(r"mul\(([0-9]+),([0-9]+)\)").unwrap();
    for (_, [first, second]) in re.captures_iter(input).map(|c| c.extract()) {
        sum += first.parse::<i32>().unwrap() * second.parse::<i32>().unwrap();
    }

    println!("Sum is {}", sum);
}

fn part2(input: &str) {
    let mut sum = 0;
    let mut active: bool = true;

    let re = Regex::new(
        r"(?<do>do\(\))|(?<dont>don't\(\))|(?<mul>mul\(([[:digit:]]+),([[:digit:]]+)\))",
    )
    .unwrap();

    for caps in re.captures_iter(input) {
        if caps.name("do").is_some() {
            active = true;
        } else if caps.name("dont").is_some() {
            active = false;
        } else if active {
            let first = caps.get(4).unwrap().as_str();
            let second = caps.get(5).unwrap().as_str();
            sum += first.parse::<i32>().unwrap() * second.parse::<i32>().unwrap();
        }
    }

    println!("Sum is {}", sum);
}
