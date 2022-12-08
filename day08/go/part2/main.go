package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type tree struct {
	height                                    int
	upCount, rightCount, downCount, leftCount int
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
		// left to right
		lrHeightPos := [10]int{}
		for i, tree := range row {
			tree.leftCount = lrHeightPos[tree.height] - i
			for j := 0; j <= tree.height; j++ {
				lrHeightPos[j] = i
			}
		}

		// right to left
		rlHeightPos := [10]int{}
		for i := 0; i < 10; i++ {
			rlHeightPos[i] = size - 1
		}
		for i := size - 1; i >= 0; i-- {
			tree := row[i]
			tree.rightCount = rlHeightPos[tree.height] - i
			for j := 0; j <= tree.height; j++ {
				rlHeightPos[j] = i
			}
		}
	}

	// columns
	for i := 0; i < size; i++ {
		// top to bottom
		tbHeightPos := [10]int{}
		for j := 0; j < size; j++ {
			tree := forest[j][i]
			tree.upCount = tbHeightPos[tree.height] - j
			for k := 0; k <= tree.height; k++ {
				tbHeightPos[k] = j
			}
		}

		btHeightPos := [10]int{}
		for i := 0; i < 10; i++ {
			btHeightPos[i] = size - 1
		}
		for j := size - 1; j >= 0; j-- {
			tree := forest[j][i]
			tree.downCount = btHeightPos[tree.height] - j
			for k := 0; k <= tree.height; k++ {
				btHeightPos[k] = j
			}
		}
	}

	maxScore := 0
	for _, row := range forest {
		for _, tree := range row {
			score := tree.upCount * tree.rightCount * tree.downCount * tree.leftCount
			if score > maxScore {
				maxScore = score
			}
		}
	}
	fmt.Print(maxScore)
}
