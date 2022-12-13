package main

import (
	"fmt"
	"math"
	"os"
	"strings"
)

type colour uint8

const (
	white colour = iota
	gray
	black
)

func main() {
	b, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	grid := strings.Split(string(b), "\n")
	grid = grid[:len(grid)-1]

	grid[0] = string(append([]byte{'a' - 1}, grid[0][1:]...))
	var dest, start *[2]int
	for y, row := range grid {
		for x, c := range row {
			if c == 'E' {
				grid[y] = string(append([]byte(grid[y][:x]),
					append([]byte{'z' + 1}, []byte(grid[y][x+1:])...)...))
				dest = &[2]int{y, x}
			} else if c == 'S' {
				grid[y] = string(append([]byte(grid[y][:x]),
					append([]byte{'a' - 1}, []byte(grid[y][x+1:])...)...))
				start = &[2]int{y, x}
			}
		}
	}

	colours := make([][]colour, len(grid))
	for i := range colours {
		colours[i] = make([]colour, len(grid[i]))
	}
	colours[start[0]][start[1]] = gray

	dists := make([][]uint, len(grid))
	for i := range dists {
		dists[i] = make([]uint, len(grid[i]))
		for j := range dists[i] {
			dists[i][j] = math.MaxUint
		}
	}
	dists[start[0]][start[1]] = 0

	// [(y, x), ...]
	queue := [][2]int{*start}

	for len(queue) > 0 {
		y, x := queue[0][0], queue[0][1]
		queue = queue[1:]

		adjacent := [][2]int{}
		if x > 0 {
			adjacent = append(adjacent, [2]int{y, x - 1})
		}
		if y > 0 {
			adjacent = append(adjacent, [2]int{y - 1, x})
		}
		if x < len(grid[0])-1 {
			adjacent = append(adjacent, [2]int{y, x + 1})
		}
		if y < len(grid)-1 {
			adjacent = append(adjacent, [2]int{y + 1, x})
		}

		for _, a := range adjacent {
			ay, ax := a[0], a[1]
			if grid[ay][ax]-1 > grid[y][x] {
				continue
			}
			if colours[ay][ax] != white {
				continue
			}
			colours[ay][ax] = gray
			queue = append(queue, a)
			dists[ay][ax] = dists[y][x] + 1
		}

		colours[y][x] = black
	}

	fmt.Print(dists[dest[0]][dest[1]])
}
