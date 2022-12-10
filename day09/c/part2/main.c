#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 512
#define LEN 10

struct xy {
  int x, y;
};

int main() {
  struct xy rope[LEN];
  for (int i = 0; i < LEN; i++) {
    rope[i].y = (rope[i].x = SIZE / 2);
  }
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

    struct xy *head = &rope[0];
    int *hc, by;
    switch (buf[0]) { 
    case 'U':
      hc = &head->y;
      by = 1;
      break;
    case 'R':
      hc = &head->x;
      by = 1;
      break;
    case 'D':
      hc = &head->y;
      by = -1;
      break;
    case 'L':
      hc = &head->x;
      by = -1;
      break;
    default:
      fprintf(stderr, "invalid input: %s\n", buf);
      return 1;
    }

    for (int i = 0; i < dist; i++) {
      *hc += by;

      for (int j = 0; j < LEN - 1; j++) {
        struct xy *l = &rope[j];
        struct xy *f = &rope[j + 1];

        int yd = l->y - f->y;
        if (yd) {
          yd /= abs(yd);
        }
        int xd = l->x - f->x;
        if (xd) {
          xd /= abs(xd);
        }
        if (l->x + 1 < f->x) {
          f->x = l->x + 1;
          f->y += yd;
        } else if (f->x < l->x - 1) {
          f->x = l->x - 1;
          f->y += yd;
        } else if (l->y + 1 < f->y) {
          f->y = l->y + 1;
          f->x += xd;
        } else if (f->y < l->y - 1) {
          f->y = l->y - 1;
          f->x += xd;
        }
      }
      struct xy tail = rope[LEN - 1];
      visited[tail.x][tail.y] = true;
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
