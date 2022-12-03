package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
)

func main() {
	r, err := os.Open("../../input")
	if err != nil {
		panic(err)
	}

	duplicates := []byte{}
	s := bufio.NewScanner(r)
OUTER:
	for s.Scan() {
		line := s.Text()
		half := len(line) / 2
		left, right := []byte(line[:half]), []byte(line[half:])
		sort.Slice(left, func(i, j int) bool { return left[i] < left[j] })
		sort.Slice(right, func(i, j int) bool { return right[i] < right[j] })

		for len(left) > 0 && len(right) > 0 {
			switch {
			case left[0] < right[0]:
				left = left[1:]
			case left[0] > right[0]:
				right = right[1:]
			default: // left[0] == right[0]
				duplicates = append(duplicates, left[0])
				continue OUTER
			}
		}

		panic("no duplicate found in " + line)
	}
	if s.Err() != nil {
		panic(s.Err())
	}

	sum := 0
	for _, b := range duplicates {
		switch {
		case 'z' >= b && b >= 'a':
			sum += int(b-'a') + 1
		case 'Z' >= b && b >= 'A':
			sum += int(b-'A') + 27
		default:
			panic("out of range duplicate " + string(b))
		}
	}

	fmt.Print(sum)
}
