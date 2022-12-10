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

	const width, height = 40, 6
	var addxV *int
	x := 1

	for cycle := 1; cycle <= width*height; cycle++ {
		rayX := (cycle - 1) % width
		if x+1 >= rayX && rayX >= x-1 {
			os.Stdout.Write([]byte{'#'})
		} else {
			os.Stdout.Write([]byte{'.'})
		}
		if rayX == width-1 {
			fmt.Println()
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
}
