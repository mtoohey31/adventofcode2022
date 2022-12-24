package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

const (
	runeOff  = ' '
	runeOpen = '.'
	runeWall = '#'
)

type dir uint8

const (
	dirRight dir = 0
	dirDown  dir = 1
	dirLeft  dir = 2
	dirUp    dir = 3
)

func (d dir) cw() dir {
	return (d + 1) % 4
}

func (d dir) ccw() dir {
	return (d - 1) % 4
}

func (d dir) _180() dir {
	return (d + 2) % 4
}

type pos struct {
	x, y int
}

func (p pos) by(d dir, v int) pos {
	switch d {
	case dirRight:
		p.x += v
	case dirDown:
		p.y += v
	case dirLeft:
		p.x -= v
	case dirUp:
		p.y -= v
	}
	return p
}

func main() {
	b, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	parts := strings.Split(strings.TrimRight(string(b), "\n"), "\n\n")
	if len(parts) != 2 {
		panic("malformed input")
	}
	boardString, pathString := parts[0], parts[1]

	// pad with 1 row/column of off the board space all around so indices line
	// up with the question and there are less conditions to handle
	boardLines := strings.Split(boardString, "\n")
	maxWidth := 0
	for _, line := range boardLines {
		if len(line) > maxWidth {
			maxWidth = len(line)
		}
	}
	board := make([]string, len(boardLines)+2)
	board[0] = strings.Repeat(string(runeOff), maxWidth+2)
	board[len(board)-1] = board[0]
	for i, line := range boardLines {
		board[i+1] = string(runeOff) + line + strings.Repeat(string(runeOff), maxWidth-len(line)+1)
	}

	// set starting values
	var initialX *int
	for x, r := range board[1] {
		if r == rune(runeOpen) {
			initialX = &x
			break
		}
	}
	if initialX == nil {
		panic("top row contained no open tile")
	}
	p := pos{x: *initialX, y: 1}
	d := dirRight

INST:
	for len(pathString) > 0 {
		switch pathString[0] {
		case 'L':
			d = d.ccw()
			pathString = pathString[1:]
			continue INST
		case 'R':
			d = d.cw()
			pathString = pathString[1:]
			continue INST
		case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
			// continue to below
		default:
			panic(fmt.Sprintf(`invalid input "%s"`, pathString))
		}

		ei := 1
		for ; ei < len(pathString); ei++ {
			switch pathString[ei] {
			case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
				continue
			}
			break
		}
		dist, err := strconv.Atoi(pathString[:ei])
		if err != nil {
			panic(err)
		}
		pathString = pathString[ei:]

	MOVE:
		for ; dist > 0; dist-- {
			oldP := p
			p = p.by(d, 1)

			switch board[p.y][p.x] {
			case runeOpen: // just leave the current value and move forward
			case runeWall: // revert position and stop
				p = oldP
				break MOVE
			case runeOff:
				// move in the other direction until we go off the board the
				// other way
				for p = p.by(d._180(), 1); board[p.y][p.x] != runeOff; p = p.by(d._180(), 1) {
				}
				// then move forward one
				p = p.by(d, 1)
				if board[p.y][p.x] == runeWall {
					// revert position and stop
					p = oldP
					break MOVE
				}
			}
		}
	}

	fmt.Print(1000*p.y + 4*p.x + int(d))
}
