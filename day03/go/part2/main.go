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

	badges := []byte{}
	s := bufio.NewScanner(r)

	var a, b, c []byte
	update := func() bool {
		if !s.Scan() {
			return false
		}
		a = []byte(s.Text())

		if !s.Scan() {
			return false
		}
		b = []byte(s.Text())

		if !s.Scan() {
			return false
		}
		c = []byte(s.Text())

		return true
	}

OUTER:
	for update() {
		sort.Slice(a, func(i, j int) bool { return a[i] < a[j] })
		sort.Slice(b, func(i, j int) bool { return b[i] < b[j] })
		sort.Slice(c, func(i, j int) bool { return c[i] < c[j] })

		for len(a) > 0 && len(b) > 0 && len(c) > 0 {
			switch {
			case a[0] < b[0]:
				a = a[1:]
			case b[0] < c[0] || a[0] > b[0]:
				b = b[1:]
			case b[0] > c[0]:
				c = c[1:]
			default: // a[0] == b[0] && b[0] == c[0]
				badges = append(badges, a[0])
				continue OUTER
			}
		}

		panic("no badge found")
	}
	if s.Err() != nil {
		panic(s.Err())
	}

	sum := 0
	for _, b := range badges {
		switch {
		case 'z' >= b && b >= 'a':
			sum += int(b-'a') + 1
		case 'Z' >= b && b >= 'A':
			sum += int(b-'A') + 27
		default:
			panic("out of range badge " + string(b))
		}
	}

	fmt.Print(sum)
}
