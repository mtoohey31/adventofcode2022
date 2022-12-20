#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 20000
#define NROCKS 5
#define CHAMBERW 7
#define ROCKMAXW 4
#define ROCKMAXH 4
// from the top of the tower
#define SPAWNYOFF 3
// from the left wall
#define SPAWNXOFF 2

const bool rocks[NROCKS][ROCKMAXH][ROCKMAXW] = {
/*
####
*/
  {
    {true,  true,  true,  true},
    {false, false, false, false},
    {false, false, false, false},
    {false, false, false, false},
  },
/*
.#.
###
.#.
*/
  {
    {false, true,  false, false},
    {true,  true,  true,  false},
    {false, true,  false, false},
    {false, false, false, false},
  },
/*
..#
..#
###
*/
  {
    {true,  true,  true,  false},
    {false, false, true,  false},
    {false, false, true,  false},
    {false, false, false, false},
  },
/*
#
#
#
#
*/
  {
    {true, false, false, false},
    {true, false, false, false},
    {true, false, false, false},
    {true, false, false, false},
  },
/*
##
##
*/
  {
    {true,  true,  false, false},
    {true,  true,  false, false},
    {false, false, false, false},
    {false, false, false, false},
  },
};

int rockw(const bool rock[ROCKMAXH][ROCKMAXW]) {
  int maxx = -1;

  for (int y = 0; y < ROCKMAXH; y++) {
    for (int x = 0; x < ROCKMAXW; x++) {
      if (rock[y][x] && x > maxx) {
        maxx = x;
      }
    }
  }

  return maxx + 1;
}

int rockh(const bool rock[ROCKMAXH][ROCKMAXW]) {
  for (int y = ROCKMAXH - 1; y >= 0; y--) {
    for (int x = 0; x < ROCKMAXW; x++) {
      if (rock[y][x]) {
        return y + 1;
      }
    }
  }

  return 0;
}

bool stopped(const bool rock[ROCKMAXH][ROCKMAXW], int rockw, int xoff, bool (*rows)[CHAMBERW], int check_rows) {
  for (int y = 0; y < check_rows; y++) {
    for (int x = 0; x < rockw; x++) {
      if (rock[y][x] && rows[y][x + xoff]) {
        return true;
      }
    }
  }

  return false;
}

int main() {
  FILE *f = fopen("../../input", "r");
  if (f == NULL) {
    perror("fopen");
    return 1;
  }

  char pattern[BUFSIZE];
  int patlen;

  if (!fgets(pattern, BUFSIZE, f)) {
    fprintf(stderr, "read failed\n");
    return 1;
  }
  if ((patlen = strnlen(pattern, BUFSIZE)) == BUFSIZE) {
    fprintf(stderr, "buffer overflow\n");
    return 1;
  }

  patlen--;

  int curr_rock, patoff, height;
  curr_rock = patoff = height = 0;
  int gridh = 128;

  bool (*grid)[CHAMBERW] = malloc(sizeof(bool[CHAMBERW]) * gridh);
  memset(grid, false, sizeof(bool[CHAMBERW]) * gridh);

  for (int i = 0; i < 2022; i++) {
    // fprintf(stderr, "i: %d\n", i);

    // 2 accounts for the 2 band section we check
    if (height + SPAWNYOFF + ROCKMAXH + 2 > gridh) {
      int new_gridh = gridh * 2;
      bool (*new_grid)[CHAMBERW] = malloc(sizeof(bool[CHAMBERW]) * new_gridh);

      memcpy(new_grid, grid, sizeof(bool[CHAMBERW]) * gridh);
      memset(new_grid + gridh, false, sizeof(bool[CHAMBERW]) * gridh);

      free(grid);

      grid = new_grid;
      gridh = new_gridh;
    }

    int xoff = SPAWNXOFF;
    int y = height + SPAWNYOFF;
    const bool (*rock)[ROCKMAXH] = rocks[curr_rock];
    int curr_rockw = rockw(rock);

    while (1) {
      int oldxoff = xoff;

      switch (pattern[patoff]) {
      case '<':
        if (xoff > 0) {
          xoff--;
        }
        break;
      case '>':
        if (xoff < CHAMBERW - curr_rockw) {
          xoff++;
        }
        break;
      default:
        fprintf(stderr, "unrecognized pattern character %c at %d\n", pattern[patoff], patoff);
        return 1;
      }

      // checks if moving would've caused overlap, if so, we restore the old
      // xoff
      if ((y == 0 && stopped(rock, curr_rockw, xoff, grid + y, 1)) ||
        (y == 1 && stopped(rock, curr_rockw, xoff, grid + y, 2)) ||
        (y == 2 && stopped(rock, curr_rockw, xoff, grid + y, 3)) ||
        stopped(rock, curr_rockw, xoff, grid + y, 4)
      ) {
        xoff = oldxoff;
        // don't break here, we might still move down
      }

      patoff++;
      patoff %= patlen;

      y--;

      if (y == -1 || (y == 0 && stopped(rock, curr_rockw, xoff, grid + y, 1)) ||
        (y == 1 && stopped(rock, curr_rockw, xoff, grid + y, 2)) ||
        (y == 2 && stopped(rock, curr_rockw, xoff, grid + y, 3)) ||
        stopped(rock, curr_rockw, xoff, grid + y, 4)
      ) {
        y++;
        break;
      }
    }

    for (int ry = 0; ry < ROCKMAXH; ry++) {
      for (int rx = 0; rx < ROCKMAXW; rx++) {
        if (rock[ry][rx]) {
          grid[y + ry][rx + xoff] = true;
        }
      }
    }

    int new_height = rockh(rock) + y;
    if (new_height > height) {
      height = new_height;
    }

    curr_rock++;
    curr_rock %= NROCKS;
  }

  printf("%d", height);

  return 0;
}
