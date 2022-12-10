package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	f, err := os.Open("../../input")
	if err != nil {
		panic(err)
	}

	s := bufio.NewScanner(f)

	var addxV *int
	x, strengthSum := 1, 0

	for cycle := 1; ; cycle++ {
		switch cycle {
		case 20, 60, 100, 140, 180, 220:
			strengthSum += cycle * x
		}

		if addxV != nil {
			x += *addxV
			addxV = nil
			continue
		}

		if !s.Scan() {
			break
		}
		line := s.Text()
		opEnd := strings.IndexByte(line, ' ')
		if opEnd == -1 {
			opEnd = len(line)
		}

		switch line[:opEnd] {
		case "addx":
			i, err := strconv.Atoi(line[opEnd+1:])
			if err != nil {
				panic(err)
			}
			addxV = &i
		case "noop":
		default:
			panic("unexpected instruction")
		}
	}
	if s.Err() != nil {
		panic(err)
	}

	fmt.Print(strengthSum)
}
