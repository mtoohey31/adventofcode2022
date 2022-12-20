#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum type {
  unknown,
  lava,
  water,
};

// assumes x,y,z is unknown or water
void mark_water(int x, int y, int z, int maxx, int maxy, int maxz, enum type ***grid) {
  if (x > 0 && grid[x-1][y][z] == unknown) {
    grid[x-1][y][z] = water;
    mark_water(x-1, y, z, maxx, maxy, maxz, grid);
  }
  if (y > 0 && grid[x][y-1][z] == unknown) {
    grid[x][y-1][z] = water;
    mark_water(x, y-1, z, maxx, maxy, maxz, grid);
  }
  if (z > 0 && grid[x][y][z-1] == unknown) {
    grid[x][y][z-1] = water;
    mark_water(x, y, z-1, maxx, maxy, maxz, grid);
  }
  if (x < maxx && grid[x+1][y][z] == unknown) {
    grid[x+1][y][z] = water;
    mark_water(x+1, y, z, maxx, maxy, maxz, grid);
  }
  if (y < maxy && grid[x][y+1][z] == unknown) {
    grid[x][y+1][z] = water;
    mark_water(x, y+1, z, maxx, maxy, maxz, grid);
  }
  if (z < maxz && grid[x][y][z+1] == unknown) {
    grid[x][y][z+1] = water;
    mark_water(x, y, z+1, maxx, maxy, maxz, grid);
  }
}

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
  enum type ***grid = malloc(sizeof(enum type**) * xlen);
  for (int x = 0; x < xlen; x++) {
    grid[x] = malloc(sizeof(enum type*) * ylen);
    for (int y = 0; y < ylen; y++) {
      grid[x][y] = malloc(sizeof(enum type) * zlen);
      memset(grid[x][y], unknown, sizeof(enum type) * zlen);
    }
  }

  // iterate again to populate grid
  if (fseek(f, 0, 0) < 0) {
    perror("fseek");
    return 1;
  }
  while (fscanf(f, "%d,%d,%d", &cx, &cy, &cz) == 3) {
    grid[cx][cy][cz] = lava;
  }

  // mark water

  // from x=0 side
  for (int y = 0; y < ylen; y++) {
    for (int z = 0; z < zlen; z++) {
      if (grid[0][y][z] == unknown) {
        mark_water(0, y, z, maxx, maxy, maxz, grid);
      }
    }
  }
  // from x=maxx side
  for (int y = 0; y < ylen; y++) {
    for (int z = 0; z < zlen; z++) {
      if (grid[maxx][y][z] == unknown) {
        mark_water(maxx, y, z, maxx, maxy, maxz, grid);
      }
    }
  }
  // from y=0 side
  for (int x = 0; x < xlen; x++) {
    for (int z = 0; z < zlen; z++) {
      if (grid[x][0][z] == unknown) {
        mark_water(x, 0, z, maxx, maxy, maxz, grid);
      }
    }
  }
  // from y=maxy side
  for (int x = 0; x < xlen; x++) {
    for (int z = 0; z < zlen; z++) {
      if (grid[x][maxy][z] == unknown) {
        mark_water(x, maxy, z, maxx, maxy, maxz, grid);
      }
    }
  }
  // from z=0 side
  for (int x = 0; x < xlen; x++) {
    for (int y = 0; y < ylen; y++) {
      if (grid[x][y][0] == unknown) {
        mark_water(x, y, 0, maxx, maxy, maxz, grid);
      }
    }
  }
  // from z=maxz side
  for (int x = 0; x < xlen; x++) {
    for (int y = 0; y < ylen; y++) {
      if (grid[x][y][maxz] == unknown) {
        mark_water(x, y, maxz, maxx, maxy, maxz, grid);
      }
    }
  }

  // iterate one last time to count accessible sides
  if (fseek(f, 0, 0) < 0) {
    perror("fseek");
    return 1;
  }
  int count = 0;
  while (fscanf(f, "%d,%d,%d", &cx, &cy, &cz) == 3) {
    if (cx == 0 || grid[cx-1][cy][cz] == water) {
      count++;
    }
    if (cy == 0 || grid[cx][cy-1][cz] == water) {
      count++;
    }
    if (cz == 0 || grid[cx][cy][cz-1] == water) {
      count++;
    }
    if (cx == maxx || grid[cx+1][cy][cz] == water) {
      count++;
    }
    if (cy == maxy || grid[cx][cy+1][cz] == water) {
      count++;
    }
    if (cz == maxz || grid[cx][cy][cz+1] == water) {
      count++;
    }
  }

  printf("%d", count);

  return 0;
}
