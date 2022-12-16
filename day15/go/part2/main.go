package main

import (
	"fmt"
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

func (s sensor) lineBetween(o sensor) line {
	oAbove := o.y > s.y
	oRight := o.x > s.x

	l := line{pos: s.pos}
	if oAbove {
		l.pos.y += s.r + 1
	} else {
		l.pos.y -= s.r + 1
	}
	if oAbove == oRight {
		l.s = 1
	} else {
		l.s = -1
	}

	return l
}

type line struct {
	pos
	s int // slope
}

func main() {
	b, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.TrimSpace(string(b)), "\n")
	sensors := make([]sensor, len(lines))
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
	}

	borderingPairs := [][2]sensor{}
	for _, s1 := range sensors {
		for _, s2 := range sensors {
			if s1.dist(s2.pos) == s1.r+s2.r+2 {
				borderingPairs = append(borderingPairs, [2]sensor{s1, s2})
			}
		}
	}

	for _, p1 := range borderingPairs {
		l1 := p1[0].lineBetween(p1[1])

	OUTER:
		for _, p2 := range borderingPairs {
			l2 := p2[0].lineBetween(p2[1])

			if l1.s == l2.s {
				// no intersection
				continue
			}

			// translate l2.pos so its x agrees with l1.pos
			l2.pos = pos{
				x: l1.pos.x,
				y: l2.pos.y - ((l1.pos.x - l2.pos.x) * l2.s),
			}

			// the y coordinate of the intersection
			yAvg := (l1.pos.y + l2.pos.y) / 2

			// candidate is l1.pos translated so its y is yAvg, aka the
			// intersection
			candidate := pos{
				x: l1.pos.x + ((l1.pos.y - yAvg) * l1.s),
				y: yAvg,
			}

			// verify that the point is just out of range of all four sensors
			for _, p := range append(p1[:], p2[:]...) {
				if p.r+1 != p.dist(candidate) {
					continue OUTER
				}
			}

			fmt.Print(candidate.x*4000000 + candidate.y)
			return
		}
	}
}
