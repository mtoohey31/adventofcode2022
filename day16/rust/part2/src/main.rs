use scanf::sscanf;
use std::{
    collections::{HashMap, HashSet, VecDeque},
    error::Error,
};

struct RawValve {
    flow_rate: usize,
    tunnels_to: Vec<String>,
}

fn shortest_paths<'a>(
    raw_graph: &'a HashMap<String, RawValve>,
    valve: &'a str,
) -> Vec<(&'a str, usize)> {
    let mut visited: HashSet<&str> = HashSet::new();
    let mut distances: HashMap<&str, usize> = HashMap::new();
    let mut queue: VecDeque<&str> = VecDeque::new();

    visited.insert(valve);
    distances.insert(valve, 0);
    queue.push_back(valve);

    while !queue.is_empty() {
        let u = queue.pop_front().unwrap();
        for v in &raw_graph.get(u).unwrap().tunnels_to {
            if !visited.contains(v.as_str()) {
                visited.insert(v);
                distances.insert(v, distances.get(u).unwrap() + 1);
                queue.push_back(v);
            }
        }
    }

    distances
        .into_iter()
        .filter(|(v, _)| v != &valve && raw_graph.get(*v).unwrap().flow_rate != 0)
        .collect()
}

#[derive(Clone)]
struct Valve<'a> {
    flow_rate: usize,
    shortest_paths_to: Vec<(&'a str, usize)>,
    open: bool,
}

fn max_pressure(
    graph: &mut HashMap<&str, Valve>,
    valve: &str,
    pressure: usize,
    tminus: usize,
) -> usize {
    let added_pressure = graph
        .values()
        .filter(|v| v.open)
        .map(|v| v.flow_rate)
        .sum::<usize>();
    if tminus == 1 {
        // Nothing we do in the next minute can increase the pressure we will
        // release by the end.
        return pressure + added_pressure;
    } else if tminus <= 0 {
        panic!();
    }

    let mut max_so_far = pressure + (added_pressure * tminus);

    for (next_valve, dist) in graph.get(valve).unwrap().shortest_paths_to.clone() {
        // if it's already open, we don't need to open it
        if graph.get(next_valve).unwrap().open {
            continue;
        }

        if dist + 1 >= tminus {
            // we can't do anything in time
            continue;
        }

        graph.get_mut(next_valve).unwrap().open = true;
        let res = max_pressure(
            graph,
            next_valve,
            pressure + (added_pressure * (dist + 1)),
            tminus - dist - 1,
        );
        max_so_far = max_so_far.max(res);
        graph.get_mut(next_valve).unwrap().open = false;
    }

    max_so_far
}

// TODO: fix this up cause it takes like 7 minutes to run on actual input
fn main() -> Result<(), Box<dyn Error>> {
    let input = std::fs::read_to_string("../../input")?;

    let mut raw_graph: HashMap<String, RawValve> = HashMap::new();

    for line in input.lines() {
        let mut valve = String::new();
        let mut flow_rate = 0;
        let mut tunnels_string = String::new();
        sscanf!(
            &line,
            "Valve {} has flow rate={}; tunnels lead to valves {}",
            valve,
            flow_rate,
            tunnels_string
        )
        .or_else(|_| {
            sscanf!(
                &line,
                "Valve {} has flow rate={}; tunnel leads to valve {}",
                valve,
                flow_rate,
                tunnels_string
            )
        })?;
        let tunnels_to = tunnels_string
            .split(", ")
            .map(str::to_owned)
            .collect::<Vec<String>>();
        raw_graph.insert(
            valve,
            RawValve {
                flow_rate,
                tunnels_to,
            },
        );
    }

    let mut graph: HashMap<&str, Valve> = HashMap::new();

    for (valve_name, raw_valve) in &raw_graph {
        if raw_valve.flow_rate == 0 && valve_name != "AA" {
            continue;
        }

        graph.insert(
            &valve_name,
            Valve {
                flow_rate: raw_valve.flow_rate,
                shortest_paths_to: shortest_paths(&raw_graph, &valve_name),
                open: false,
            },
        );
    }

    let mut max_so_far = 0;

    let flowable_valves: Vec<&str> = graph.keys().filter(|v| v != &&"AA").map(|v| *v).collect();
    let kmax = 2_u32.pow(flowable_valves.len() as u32);
    for k in 0..kmax {
        let (pvalves, evalves): (Vec<_>, Vec<_>) = flowable_valves
            .iter()
            .enumerate()
            .partition(|(i, _)| (1_u32 << *i as u32) & k != 0);

        let pvalves = pvalves.into_iter().map(|(_, v)| v).collect::<Vec<_>>();
        let evalves = evalves.into_iter().map(|(_, v)| v).collect::<Vec<_>>();

        let mut pgraph: HashMap<&str, Valve> = graph
            .iter()
            .filter(|(v, _)| pvalves.contains(v))
            .map(|(vn, v)| {
                (
                    *vn,
                    Valve {
                        shortest_paths_to: v
                            .shortest_paths_to
                            .iter()
                            .filter(|(v, _)| pvalves.contains(&v))
                            .map(|t| *t)
                            .collect(),
                        ..v.clone()
                    },
                )
            })
            .collect();
        let mut egraph: HashMap<&str, Valve> = graph
            .iter()
            .filter(|(v, _)| evalves.contains(v))
            .map(|(vn, v)| {
                (
                    *vn,
                    Valve {
                        shortest_paths_to: v
                            .shortest_paths_to
                            .iter()
                            .filter(|(v, _)| evalves.contains(&v))
                            .map(|t| *t)
                            .collect(),
                        ..v.clone()
                    },
                )
            })
            .collect();

        let mut pmax_so_far = 0;
        let mut emax_so_far = 0;

        for (valve, dist) in graph.get("AA").unwrap().shortest_paths_to.clone() {
            if !pgraph.contains_key(valve) {
                continue;
            }

            pgraph.get_mut(valve).unwrap().open = true;
            let res = max_pressure(&mut pgraph, valve, 0, 26 - dist - 1);
            pmax_so_far = pmax_so_far.max(res);
            pgraph.get_mut(valve).unwrap().open = false;
        }
        for (valve, dist) in graph.get("AA").unwrap().shortest_paths_to.clone() {
            if !egraph.contains_key(valve) {
                continue;
            }

            egraph.get_mut(valve).unwrap().open = true;
            let res = max_pressure(&mut egraph, valve, 0, 26 - dist - 1);
            emax_so_far = emax_so_far.max(res);
            egraph.get_mut(valve).unwrap().open = false;
        }
        max_so_far = max_so_far.max(pmax_so_far + emax_so_far);
    }

    print!("{}", max_so_far);

    Ok(())
}
