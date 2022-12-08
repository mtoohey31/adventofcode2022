package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type tree struct {
	height  int
	visible bool
}

func main() {
	input, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(input), "\n")
	lines = lines[:len(lines)-1]
	size := len(lines)

	forest := make([][]*tree, size)
	for i, line := range lines {
		if len(line) != size {
			panic("unexpected line length")
		}
		forest[i] = make([]*tree, size)
		for j, char := range line {
			forest[i][j] = new(tree)
			forest[i][j].height, err = strconv.Atoi(string(char))
			if err != nil {
				panic(err)
			}
		}
	}

	// rows
	for _, row := range forest {
		// left to right check
		lrMax := -1
		for _, tree := range row {
			if tree.height > lrMax {
				tree.visible = true
				lrMax = tree.height
			}
		}

		// right to left check
		rlMax := -1
		for i := size - 1; i >= 0; i-- {
			tree := row[i]
			if tree.height > rlMax {
				tree.visible = true
				rlMax = tree.height
			}
		}
	}

	// columns
	for i := 0; i < size; i++ {
		// top to bottom check
		tbMax := -1
		for j := 0; j < size; j++ {
			tree := forest[j][i]
			if tree.height > tbMax {
				tree.visible = true
				tbMax = tree.height
			}
		}

		// bottom to top check
		btMax := -1
		for j := size - 1; j >= 0; j-- {
			tree := forest[j][i]
			if tree.height > btMax {
				tree.visible = true
				btMax = tree.height
			}
		}
	}

	visible := 0
	for _, row := range forest {
		for _, tree := range row {
			if tree.visible {
				visible++
			}
		}
	}
	fmt.Print(visible)
}
