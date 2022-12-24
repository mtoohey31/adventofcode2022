use std::{
    collections::{HashMap, HashSet},
    error::Error,
};

#[derive(Clone, Copy)]
enum Dir {
    Right,
    Down,
    Left,
    Up,
}

impl TryFrom<char> for Dir {
    type Error = ();

    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            '>' => Ok(Self::Right),
            'v' => Ok(Self::Down),
            '<' => Ok(Self::Left),
            '^' => Ok(Self::Up),
            _ => Err(()),
        }
    }
}

struct BlizzardTracker {
    map: HashMap<(usize, usize), Vec<Dir>>,
    valley_w: usize,
    valley_h: usize,
}

impl BlizzardTracker {
    fn new(valley_w: usize, valley_h: usize) -> Self {
        BlizzardTracker {
            map: HashMap::new(),
            valley_w,
            valley_h,
        }
    }

    fn add(&mut self, (y, x): (usize, usize), d: Dir) {
        self.map.entry((y, x)).or_insert(Vec::new()).push(d);
    }

    // valley_w/h are the distances of open space between the walls, so 5 for the example input
    fn advanced(&self) -> Self {
        let mut advanced = BlizzardTracker {
            map: HashMap::new(),
            ..*self
        };
        for ((y, x), ds) in &self.map {
            for d in ds {
                let new_pos = match d {
                    Dir::Right => {
                        if *x == self.valley_w {
                            (*y, 1)
                        } else {
                            (*y, x + 1)
                        }
                    }
                    Dir::Down => {
                        if *y == self.valley_h {
                            (1, *x)
                        } else {
                            (y + 1, *x)
                        }
                    }
                    Dir::Left => {
                        if *x == 1 {
                            (*y, self.valley_w)
                        } else {
                            (*y, x - 1)
                        }
                    }
                    Dir::Up => {
                        if *y == 1 {
                            (self.valley_h, *x)
                        } else {
                            (y - 1, *x)
                        }
                    }
                };
                advanced.add(new_pos, *d);
            }
        }
        advanced
    }

    fn blocked(&self, (y, x): (usize, usize)) -> bool {
        self.map.contains_key(&(y, x))
    }
}

#[derive(PartialEq, Eq, Hash, Clone)]
struct State {
    pos: (usize, usize),
    reached_end: bool,
    reached_start: bool,
}

impl State {
    fn with_pos(&self, pos: (usize, usize)) -> Self {
        Self { pos, ..*self }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let input = std::fs::read_to_string("../../input")?;

    let lines: Vec<&str> = input.lines().collect();
    let (valley_w, valley_h) = (lines[0].len() - 2, lines.len() - 2);
    let mut tracker = BlizzardTracker::new(valley_w, valley_h);
    for (y, line) in lines[..lines.len() - 1].iter().enumerate().skip(1) {
        for (x, c) in line[..lines[0].len() - 1].chars().enumerate().skip(1) {
            if c == '.' {
                continue;
            }

            tracker.add((y, x), c.try_into().unwrap());
        }
    }

    let origin = (0, 1);
    let origin_adjacent = (1, 1);
    let end = (valley_h + 1, valley_w);
    let end_adjacent = (valley_h, valley_w);
    let mut curr_posns = HashSet::new();
    curr_posns.insert(State {
        pos: origin,
        reached_end: false,
        reached_start: false,
    });

    for moves in 1.. {
        tracker = tracker.advanced();
        let mut next_posns = HashSet::new();

        for s @ State {
            pos,
            reached_end,
            reached_start,
        } in curr_posns
        {
            if pos == origin {
                next_posns.insert(s.clone());
                if !tracker.blocked(origin_adjacent) {
                    next_posns.insert(s.with_pos(origin_adjacent));
                }
                // for the origin, skip the other stuff cause the usual rules
                // don't apply so we'd have to add a bunch of conditions below
                // to keep things out of the walls
                continue;
            }

            if pos == end {
                next_posns.insert(s.clone());
                if !tracker.blocked(end_adjacent) {
                    next_posns.insert(s.with_pos(end_adjacent));
                }
                // same deal here
                continue;
            }

            // move to end
            if pos == end_adjacent && reached_end && reached_start {
                print!("{}", moves);
                return Ok(());
            }

            let (y, x) = pos;

            // move to origin
            if pos == origin_adjacent {
                // origin can never be blocked
                if reached_end && !reached_start {
                    next_posns.insert(State {
                        pos: origin,
                        reached_end,
                        reached_start: true,
                    });
                } else {
                    next_posns.insert(s.with_pos(origin));
                }
            }

            // move to end
            if pos == end_adjacent {
                // end can never be blocked
                if !reached_end {
                    next_posns.insert(State {
                        pos: end,
                        reached_end: true,
                        reached_start,
                    });
                } else {
                    next_posns.insert(s.with_pos(end));
                }
            }

            // stay still
            if !tracker.blocked(pos) {
                next_posns.insert(s.with_pos(pos));
            }

            // move right
            if x < valley_w && !tracker.blocked((y, x + 1)) {
                next_posns.insert(s.with_pos((y, x + 1)));
            }

            // move down
            if y < valley_h && !tracker.blocked((y + 1, x)) {
                next_posns.insert(s.with_pos((y + 1, x)));
            }

            // move left
            if x > 1 && !tracker.blocked((y, x - 1)) {
                next_posns.insert(s.with_pos((y, x - 1)));
            }

            // move up
            if y > 1 && !tracker.blocked((y - 1, x)) {
                next_posns.insert(s.with_pos((y - 1, x)));
            }
        }

        curr_posns = next_posns;
    }

    Ok(())
}
