package main

import (
	"fmt"
	"math"
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

func (p pos) _180InFace(faceDim int) pos {
	xInFace := (p.x - 1) % faceDim
	xdFromNext := faceDim - xInFace - 1
	xOfFace := p.x - xInFace

	yInFace := (p.y - 1) % faceDim
	ydFromNext := faceDim - yInFace - 1
	yOfFace := p.y - yInFace
	return pos{
		x: xOfFace + xdFromNext,
		y: yOfFace + ydFromNext,
	}
}

func (p pos) cwInFace(faceDim int) pos {
	xInFace := (p.x - 1) % faceDim
	// xdFromNext := faceDim - xInFace - 1
	xOfFace := p.x - xInFace

	yInFace := (p.y - 1) % faceDim
	ydFromNext := faceDim - yInFace - 1
	yOfFace := p.y - yInFace
	return pos{
		x: xOfFace + ydFromNext,
		y: yOfFace + xInFace,
	}
}

func (p pos) ccwInFace(faceDim int) pos {
	xInFace := (p.x - 1) % faceDim
	xdFromNext := faceDim - xInFace - 1
	xOfFace := p.x - xInFace

	yInFace := (p.y - 1) % faceDim
	// ydFromNext := faceDim - yInFace - 1
	yOfFace := p.y - yInFace
	return pos{
		x: xOfFace + yInFace,
		y: yOfFace + xdFromNext,
	}
}

type rotatorPair struct {
	dirRot func(dir) dir
	posRot func(pos, int) pos
}

var rotatorPairs = []rotatorPair{
	{
		dirRot: dir.cw,
		posRot: pos.cwInFace,
	},
	{
		dirRot: dir.ccw,
		posRot: pos.ccwInFace,
	},
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
	totalSpaces := 0
	for i, line := range boardLines {
		board[i+1] = string(runeOff) + line + strings.Repeat(string(runeOff), maxWidth-len(line)+1)
		for _, r := range line {
			switch r {
			case runeOpen, runeWall:
				totalSpaces++
			}
		}
	}
	faceDim := int(math.Sqrt(float64(totalSpaces / 6)))
	inBoard := func(p pos) bool {
		return p.x > 0 && p.x < len(board[0]) && p.y > 0 && p.y < len(board) && board[p.y][p.x] != runeOff
	}
	allInBoard := func(ps ...pos) bool {
		for _, p := range ps {
			if !inBoard(p) {
				return false
			}
		}
		return true
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
			oldP, oldD := p, d
			p = p.by(d, 1)

			switch board[p.y][p.x] {
			case runeOpen: // just leave the current value and move forward
			case runeWall: // revert position and stop
				p = oldP
				break MOVE
			case runeOff:
				// check adjacency pattern:
				//
				// FB
				// A1
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(pair.dirRot(d), faceDim)
					b := _1.by(d, faceDim)
					if allInBoard(a, _1, b) {
						p = pair.posRot(b, faceDim)
						d = pair.dirRot(d)
						goto WALL
					}
				}

				// check adjacency pattern:
				//
				// F
				// A
				// 12B
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(d, -faceDim)
					_2 := _1.by(pair.dirRot(d), faceDim)
					b := _2.by(pair.dirRot(d), faceDim)
					if allInBoard(a, _1, _2, b) {
						p = b._180InFace(faceDim)
						d = d._180()
						goto WALL
					}
				}

				// check adjacency pattern:
				//
				//  F
				//  A
				//  1
				// 32
				// B
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(d, -faceDim)
					_2 := _1.by(d, -faceDim)
					_3 := _2.by(pair.dirRot(pair.dirRot(pair.dirRot(d))), faceDim)
					b := _3.by(d, -faceDim)
					if allInBoard(a, _1, _2, _3, b) {
						p = pair.posRot(b, faceDim)
						d = pair.dirRot(d)
						goto WALL
					}
				}

				// check adjacency pattern:
				//
				// F
				// A1
				//  23B
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(pair.dirRot(pair.dirRot(pair.dirRot(d))), faceDim)
					_2 := _1.by(d, -faceDim)
					_3 := _2.by(pair.dirRot(pair.dirRot(pair.dirRot(d))), faceDim)
					b := _3.by(pair.dirRot(pair.dirRot(pair.dirRot(d))), faceDim)
					if allInBoard(a, _1, _2, _3, b) {
						p = pair.posRot(b, faceDim)
						d = pair.dirRot(d)
						goto WALL
					}
				}

				// check adjacency pattern:
				//
				// F
				// A
				// 12
				//  3
				//  4B
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(d, -faceDim)
					_2 := _1.by(pair.dirRot(d), faceDim)
					_3 := _2.by(d, -faceDim)
					_4 := _3.by(d, -faceDim)
					b := _4.by(pair.dirRot(d), faceDim)
					if allInBoard(a, _1, _2, _3, _4, b) {
						p = b
						goto WALL
					}
				}

				// check adjacency pattern:
				//
				// F
				// A1
				//  2
				//  34
				//   B
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(pair.dirRot(d), faceDim)
					_2 := _1.by(d, -faceDim)
					_3 := _2.by(d, -faceDim)
					_4 := _3.by(pair.dirRot(d), faceDim)
					b := _4.by(d, -faceDim)
					if allInBoard(a, _1, _2, _3, _4, b) {
						p = b
						goto WALL
					}
				}

				// check adjacency pattern:
				//
				// F B
				// A12
				for _, pair := range rotatorPairs {
					a := p.by(d, -faceDim)
					_1 := a.by(pair.dirRot(d), faceDim)
					_2 := _1.by(pair.dirRot(d), faceDim)
					b := _2.by(d, faceDim)
					if allInBoard(a, _1, _2, b) {
						p = b._180InFace(faceDim)
						d = d._180()
						goto WALL
					}
				}

				panic(fmt.Sprintf("no adjacency match at %v", p))

			WALL:
				if board[p.y][p.x] == runeWall {
					// revert old position and direction
					p, d = oldP, oldD
					break MOVE
				}
			}
		}
	}

	fmt.Print(1000*p.y + 4*p.x + int(d))
}
