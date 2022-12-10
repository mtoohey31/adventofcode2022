#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 512

int main() {
  int hx, hy, tx, ty;
  hx = (hy = (tx = (ty = SIZE / 2)));
  bool visited[SIZE][SIZE];
  memset(visited, false, sizeof(bool) * SIZE * SIZE);
  visited[SIZE / 2][SIZE / 2] = true;

  FILE *f = fopen("../../input", "r");
  char buf[64];

  while (fgets(buf, 64, f)) {
    int l = strnlen(buf, 64);
    if (l == 64) {
      fprintf(stderr, "buffer overflow\n");
      return 1;
    } else if (l < 3) {
      fprintf(stderr, "invalid input: %s\n", buf);
      return 1;
    }

    char *nl = strchr(buf, '\n');
    if (!nl) {
      fprintf(stderr, "invalid input: %s\n", buf);
      return 1;
    }
    *nl = '\0';

    int dist = atoi(buf + 2);

    bool vertical;
    int by;
    switch (buf[0]) { 
    case 'U':
      vertical = true;
      by = 1;
      break;
    case 'R':
      vertical = false;
      by = 1;
      break;
    case 'D':
      vertical = true;
      by = -1;
      break;
    case 'L':
      vertical = false;
      by = -1;
      break;
    default:
      fprintf(stderr, "invalid input: %s\n", buf);
      return 1;
    }

    int *hc, *ho, *tc, *to;
    if (vertical) {
      hc = &hy;
      ho = &hx;
      tc = &ty;
      to = &tx;
    } else {
      hc = &hx;
      ho = &hy;
      tc = &tx;
      to = &ty;
    }

    for (int i = 0; i < dist; i++) {
      *hc += by;
      if (hx + 1 < tx || tx < hx - 1 || hy + 1 < ty || ty < hy - 1) {
        *tc = *hc - by;
        *to = *ho;
        visited[tx][ty] = true;
      }
    }
  }

  int npos = 0;
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      npos += visited[i][j];
    }
  }
  printf("%d", npos);
  return 0;
}
