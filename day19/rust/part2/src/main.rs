use scanf::sscanf;
use std::error::Error;

#[derive(Debug)]
struct Blueprint {
    ore_ore_cost: usize,
    clay_ore_cost: usize,
    obsidian_ore_cost: usize,
    obsidian_clay_cost: usize,
    geode_ore_cost: usize,
    geode_obsidian_cost: usize,
}

#[derive(Debug, Clone)]
struct Resources {
    ore: usize,
    ore_rate: usize,
    clay: usize,
    clay_rate: usize,
    obsidian: usize,
    obsidian_rate: usize,
    geodes: usize,
    geode_rate: usize,
}

impl Resources {
    fn after(&self, m: usize) -> Resources {
        Resources {
            ore: self.ore + (self.ore_rate * m),
            clay: self.clay + (self.clay_rate * m),
            obsidian: self.obsidian + (self.obsidian_rate * m),
            geodes: self.geodes + (self.geode_rate * m),
            ..self.clone()
        }
    }
}

fn div_ceil(a: usize, b: usize) -> usize {
    let d = a / b;
    let r = a % b;
    if r > 0 && b > 0 {
        d + 1
    } else {
        d
    }
}

const MAX_ORE_RATE: usize = 4;

fn max_geodes(b: &Blueprint, r: &Resources, m: usize) -> usize {
    let mut max_so_far = r.after(m).geodes; // buy nothing

    if m <= 1 {
        return max_so_far;
    }

    // buy ore robot next
    {
        let time_to_ore = div_ceil(b.ore_ore_cost.saturating_sub(r.ore), r.ore_rate) + 1;
        if time_to_ore < m && r.ore_rate < MAX_ORE_RATE {
            max_so_far = max_so_far.max(max_geodes(
                b,
                &Resources {
                    ore: r.ore + (r.ore_rate * time_to_ore) - b.ore_ore_cost,
                    ore_rate: r.ore_rate + 1,
                    ..r.after(time_to_ore)
                },
                m - time_to_ore,
            ));
        }
    }
    // buy clay robot next
    {
        let time_to_clay = div_ceil(b.clay_ore_cost.saturating_sub(r.ore), r.ore_rate) + 1;
        if time_to_clay < m {
            max_so_far = max_so_far.max(max_geodes(
                b,
                &Resources {
                    ore: r.ore + (r.ore_rate * time_to_clay) - b.clay_ore_cost,
                    clay_rate: r.clay_rate + 1,
                    ..r.after(time_to_clay)
                },
                m - time_to_clay,
            ));
        }
    }
    // buy obsidian robot next
    if r.clay_rate > 0 {
        let time_to_obsidian = div_ceil(b.obsidian_ore_cost.saturating_sub(r.ore), r.ore_rate).max(
            div_ceil(b.obsidian_clay_cost.saturating_sub(r.clay), r.clay_rate),
        ) + 1;
        if time_to_obsidian < m {
            max_so_far = max_so_far.max(max_geodes(
                b,
                &Resources {
                    ore: r.ore + (r.ore_rate * time_to_obsidian) - b.obsidian_ore_cost,
                    clay: r.clay + (r.clay_rate * time_to_obsidian) - b.obsidian_clay_cost,
                    obsidian_rate: r.obsidian_rate + 1,
                    ..r.after(time_to_obsidian)
                },
                m - time_to_obsidian,
            ));
        }
    }
    // buy geode robot next
    if r.obsidian_rate > 0 {
        let time_to_geode =
            div_ceil(b.geode_ore_cost.saturating_sub(r.ore), r.ore_rate).max(div_ceil(
                b.geode_obsidian_cost.saturating_sub(r.obsidian),
                r.obsidian_rate,
            )) + 1;
        if time_to_geode < m {
            max_so_far = max_so_far.max(max_geodes(
                b,
                &Resources {
                    ore: r.ore + (r.ore_rate * time_to_geode) - b.geode_ore_cost,
                    obsidian: r.obsidian + (r.obsidian_rate * time_to_geode)
                        - b.geode_obsidian_cost,
                    geode_rate: r.geode_rate + 1,
                    ..r.after(time_to_geode)
                },
                m - time_to_geode,
            ));
        }
    }

    max_so_far
}

fn main() -> Result<(), Box<dyn Error>> {
    let input = std::fs::read_to_string("../../input")?;

    let mut blueprints = Vec::new();

    for line in input.lines() {
        let mut idx = 0;
        let mut ore_ore_cost = 0;
        let mut clay_ore_cost = 0;
        let mut obsidian_ore_cost = 0;
        let mut obsidian_clay_cost = 0;
        let mut geode_ore_cost = 0;
        let mut geode_obsidian_cost = 0;
        sscanf!(
            &line,
            "Blueprint {}: Each ore robot costs {} ore. Each clay robot costs {} ore. Each obsidian robot costs {} ore and {} clay. Each geode robot costs {} ore and {} obsidian.",
            idx,
            ore_ore_cost,
            clay_ore_cost,
            obsidian_ore_cost,
            obsidian_clay_cost,
            geode_ore_cost,
            geode_obsidian_cost,
        )?;

        blueprints.push(Blueprint {
            ore_ore_cost,
            clay_ore_cost,
            obsidian_ore_cost,
            obsidian_clay_cost,
            geode_ore_cost,
            geode_obsidian_cost,
        });
    }

    let answer: usize = blueprints[0..3]
        .iter()
        .map(|b| {
            max_geodes(
                b,
                &Resources {
                    ore: 0,
                    ore_rate: 1,
                    clay: 0,
                    clay_rate: 0,
                    obsidian: 0,
                    obsidian_rate: 0,
                    geodes: 0,
                    geode_rate: 0,
                },
                32,
            )
        })
        .product();

    print!("{}", answer);

    Ok(())
}
