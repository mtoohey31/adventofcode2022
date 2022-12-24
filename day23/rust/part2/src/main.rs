use std::{collections::HashMap, error::Error};

const PADDING: usize = 64;

#[derive(Clone, Copy)]
enum Dir {
    North,
    East,
    South,
    West,
}

impl Dir {
    fn next(&self) -> Dir {
        match self {
            Self::North => Self::South,
            Self::South => Self::West,
            Self::West => Self::East,
            Self::East => Self::North,
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let input = std::fs::read_to_string("../../input")?;

    let mut grid: Vec<Vec<bool>> = input
        .lines()
        .map(|l| {
            l.chars()
                .map(|c| match c {
                    '#' => true,
                    '.' => false,
                    _ => panic!("invalid input '{}'", c),
                })
                .collect()
        })
        .collect();
    for row in grid.iter_mut() {
        for _ in 0..PADDING {
            row.insert(0, false);
            row.push(false);
        }
    }
    for _ in 0..PADDING {
        grid.insert(0, vec![false].repeat(grid[0].len()));
        grid.push(vec![false].repeat(grid[0].len()));
    }

    let mut first_check_dir = Dir::North;

    for round in 1.. {
        // make claims, which are a map from the claimed space to a list of the current positions
        // of elves who want to that space
        let mut claims: HashMap<(usize, usize), Vec<(usize, usize)>> = HashMap::new();
        for (y, row) in grid.iter().enumerate() {
            for (x, cell) in row.iter().enumerate() {
                if !cell {
                    // no elf
                    continue;
                }

                if !grid[y - 1][x - 1..x + 2].iter().any(|&b| b)
                    && !grid[y][x - 1]
                    && !grid[y][x + 1]
                    && !grid[y + 1][x - 1..x + 2].iter().any(|&b| b)
                {
                    // no adjacent elves
                    continue;
                }

                let mut check_dir = first_check_dir;
                for _ in 0..4 {
                    match check_dir {
                        Dir::North => {
                            if !grid[y - 1][x - 1..x + 2].iter().any(|&b| b) {
                                claims.entry((y - 1, x)).or_insert(Vec::new()).push((y, x));
                                break;
                            }
                        }
                        Dir::East => {
                            if !grid[y - 1..y + 2].iter().any(|row| row[x + 1]) {
                                claims.entry((y, x + 1)).or_insert(Vec::new()).push((y, x));
                                break;
                            }
                        }
                        Dir::South => {
                            if !grid[y + 1][x - 1..x + 2].iter().any(|&b| b) {
                                claims.entry((y + 1, x)).or_insert(Vec::new()).push((y, x));
                                break;
                            }
                        }
                        Dir::West => {
                            if !grid[y - 1..y + 2].iter().any(|row| row[x - 1]) {
                                claims.entry((y, x - 1)).or_insert(Vec::new()).push((y, x));
                                break;
                            }
                        }
                    };

                    check_dir = check_dir.next();
                }
            }
        }

        // move elves to places that only have one claim
        let mut to_move = claims
            .into_iter()
            .filter(|(_, origins)| origins.len() == 1)
            .peekable();
        if to_move.peek().is_none() {
            // no elves moved, so we're done
            print!("{}", round);
            break;
        }
        for (dest, origin_singleton) in to_move {
            let origin = origin_singleton[0];
            grid[origin.0][origin.1] = false;
            grid[dest.0][dest.1] = true;
        }

        first_check_dir = first_check_dir.next();
    }

    Ok(())
}
