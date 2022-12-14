package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

func main() {
	b, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	sandOrigin := [2]int{0, 500}

	lineStrings := strings.Split(strings.TrimSpace(string(b)), "\n")
	lines := make([][][2]int, len(lineStrings))
	xMax, yMax := sandOrigin[1], math.MinInt
	xMin, yMin := math.MaxInt, sandOrigin[0]
	for i, ls := range lineStrings {
		pointStrings := strings.Split(ls, " -> ")
		lines[i] = make([][2]int, len(pointStrings))
		for j, ps := range pointStrings {
			coords := strings.Split(ps, ",")

			if len(coords) != 2 {
				panic("invalid point :" + ps)
			}
			x, err := strconv.Atoi(coords[0])

			if err != nil {
				panic(err)
			}

			y, err := strconv.Atoi(coords[1])
			if err != nil {
				panic(err)
			}

			lines[i][j] = [2]int{y, x}
			if x > xMax {
				xMax = x
			}
			if y > yMax {
				yMax = y
			}
			if x < xMin {
				xMin = x
			}
			if y < yMin {
				yMin = y
			}
		}
	}

	for _, line := range lines {
		for j := range line {
			line[j][0] -= yMin
			line[j][1] -= xMin
		}
	}
	sandOrigin[0] -= yMin
	sandOrigin[1] -= xMin

	grid := make([][]bool, yMax-yMin+1)
	for i := range grid {
		grid[i] = make([]bool, xMax-xMin+1)
	}

	for _, line := range lines {
		prev := line[0]
		grid[prev[0]][prev[1]] = true

		line = line[1:]

		for len(line) > 0 {
			curr := line[0]
			line = line[1:]

			if curr[0] == prev[0] {
				var inc int
				if curr[1] > prev[1] {
					inc = -1
				} else {
					inc = 1
				}
				for i := curr[1] + inc; i != prev[1]; i += inc {
					grid[curr[0]][i] = true
				}
			} else if curr[1] == prev[1] {
				var inc int
				if curr[0] > prev[0] {
					inc = -1
				} else {
					inc = 1
				}
				for i := curr[0] + inc; i != prev[0]; i += inc {
					grid[i][curr[1]] = true
				}
			} else {
				panic("diagonal line encountered")
			}

			prev = curr
			grid[prev[0]][prev[1]] = true
		}
	}

	i := 0
OUTER:
	for ; ; i++ {
		sand := sandOrigin
	INNER:
		for {
			switch {
			case sand[0]+1 == len(grid): // if we'd go off downwards
				break OUTER
			case !grid[sand[0]+1][sand[1]]: // try down
				sand[0]++
			case sand[1] == 0: // if we'd go off left
				break OUTER
			case !grid[sand[0]+1][sand[1]-1]: // try down left
				sand[0]++
				sand[1]--
			case sand[1]+1 == len(grid[1]): // if we'd go off right
				break OUTER
			case !grid[sand[0]+1][sand[1]+1]: // try down right
				sand[0]++
				sand[1]++
			default:
				grid[sand[0]][sand[1]] = true
				break INNER
			}
		}
	}

	fmt.Print(i)
}
