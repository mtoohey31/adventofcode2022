package main

import (
	"fmt"
	"math"
	"os"
	"strings"
)

func abs(i int) int {
	if i > 0 {
		return i
	}
	return -i
}

type pos struct {
	x, y int
}

func (c pos) dist(o pos) int {
	return abs(c.x-o.x) + abs(c.y-o.y)
}

type sensor struct {
	pos
	r int // range
}

func main() {
	b, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.TrimSpace(string(b)), "\n")
	sensors := make([]sensor, len(lines))
	sensorPosSet := map[pos]struct{}{}
	beaconPosSet := map[pos]struct{}{}
	xMin, xMax := math.MaxInt, math.MinInt
	for i, line := range lines {
		var s sensor
		var b pos
		n, err := fmt.Sscanf(line, "Sensor at x=%d, y=%d: closest beacon is at x=%d, y=%d",
			&s.x, &s.y, &b.x, &b.y)
		if err != nil {
			panic(err)
		}
		if n != 4 {
			panic("Sscanf didn't match all 4 values")
		}

		s.r = s.pos.dist(b)

		sensors[i] = s
		sensorPosSet[s.pos] = struct{}{}
		beaconPosSet[b] = struct{}{}

		if s.x-s.r < xMin {
			xMin = s.x - s.r
		}
		if s.x+s.r > xMax {
			xMax = s.x + s.r
		}
	}

	const targetRow int = 2000000
	noBeaconCount := 0
	c := pos{x: xMin, y: targetRow}
	for ; c.x <= xMax; c.x++ {
		if _, ok := sensorPosSet[c]; ok {
			noBeaconCount++
		} else if _, ok := beaconPosSet[c]; !ok {
			for _, s := range sensors {
				if s.r >= s.dist(c) {
					noBeaconCount++
					break
				}
			}
		}
	}
	fmt.Print(noBeaconCount)
}
