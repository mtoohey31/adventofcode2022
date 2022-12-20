#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  FILE *f = fopen("../../input", "r");
  if (f == NULL) {
    perror("fopen");
    return 1;
  }

  int maxx, maxy, maxz;
  maxx = maxy = maxz = 0;

  // iterate once to find max values
  int cx, cy, cz;
  while (fscanf(f, "%d,%d,%d", &cx, &cy, &cz) == 3) {
    if (cx > maxx) {
      maxx = cx;
    }
    if (cy > maxy) {
      maxy = cy;
    }
    if (cz > maxz) {
      maxz = cz;
    }
  }

  int xlen, ylen, zlen;
  xlen = maxx + 1;
  ylen = maxy + 1;
  zlen = maxz + 1;
  bool ***grid = malloc(sizeof(bool**) * xlen);
  for (int x = 0; x < xlen; x++) {
    grid[x] = malloc(sizeof(bool*) * ylen);
    for (int y = 0; y < ylen; y++) {
      grid[x][y] = malloc(sizeof(bool) * zlen);
      memset(grid[x][y], false, sizeof(bool) * zlen);
    }
  }

  // iterate again to populate grid
  if (fseek(f, 0, 0) < 0) {
    perror("fseek");
    return 1;
  }
  while (fscanf(f, "%d,%d,%d", &cx, &cy, &cz) == 3) {
    grid[cx][cy][cz] = true;
  }

  // iterate one last time to count exposed sides
  if (fseek(f, 0, 0) < 0) {
    perror("fseek");
    return 1;
  }
  int count = 0;
  while (fscanf(f, "%d,%d,%d", &cx, &cy, &cz) == 3) {
    if (cx == 0 || !grid[cx-1][cy][cz]) {
      count++;
    }
    if (cy == 0 || !grid[cx][cy-1][cz]) {
      count++;
    }
    if (cz == 0 || !grid[cx][cy][cz-1]) {
      count++;
    }
    if (cx == maxx || !grid[cx+1][cy][cz]) {
      count++;
    }
    if (cy == maxy || !grid[cx][cy+1][cz]) {
      count++;
    }
    if (cz == maxz || !grid[cx][cy][cz+1]) {
      count++;
    }
  }

  printf("%d", count);

  return 0;
}
