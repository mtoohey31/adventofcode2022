package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	input, err := os.ReadFile("../../input")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(input), "\n")
	lines = lines[:len(lines)-1]
	size := len(lines)

	forest := make([][]int, size)
	for i, line := range lines {
		if len(line) != size {
			panic("unexpected line length")
		}
		forest[i] = make([]int, size)
		for j, char := range line {
			forest[i][j], err = strconv.Atoi(string(char))
			if err != nil {
				panic(err)
			}
		}
	}

	maxScore := 0

	for i, row := range forest {
		if i == 0 || i == size-1 {
			// up/down distance will be zero; so will score
			continue
		}

		for j, tree := range row {
			if j == 0 || j == size-1 {
				// left/right distance will be zero; so will score
				continue
			}

			upCount, rightCount, downCount, leftCount := 1, 1, 1, 1

			// up
			for k := i - 1; k > 0 && forest[k][j] < tree; k-- {
				upCount++
			}

			// right
			for k := j + 1; k < size-1 && forest[i][k] < tree; k++ {
				rightCount++
			}

			// down
			for k := i + 1; k < size-1 && forest[k][j] < tree; k++ {
				downCount++
			}

			// left
			for k := j - 1; k > 0 && forest[i][k] < tree; k-- {
				leftCount++
			}

			score := upCount * rightCount * downCount * leftCount
			if score > maxScore {
				maxScore = score
			}
		}
	}

	fmt.Print(maxScore)
}
