#include <stdio.h>

#define MARKER_WIDTH 4

void add_char(char c, int* rep_count, int* char_counts) {
  if (char_counts[c - 'a'] == 1) {
    *rep_count = (*rep_count) + 1;
  }
  char_counts[c - 'a']++;
}

void rem_char(char c, int* rep_count, int* char_counts) {
  if (char_counts[c - 'a'] == 2) {
    *rep_count = (*rep_count) - 1;
  }
  char_counts[c - 'a']--;
}

int main() {
  FILE* f = fopen("../../input", "r");
  if (f == NULL) {
    perror("fopen");
    return 1;
  }

  int buf[MARKER_WIDTH];
  int buf_off = 3;

  int rep_count = 0;
  int char_counts[26];
  for (int i = 0; i < 26; i++) {
    char_counts[i] = 0;
  }

  for (int i = 0; i < MARKER_WIDTH; i++) {
    buf_off++;
    buf_off %= MARKER_WIDTH;
    buf[buf_off] = fgetc(f);
    if ('a' > buf[buf_off] || buf[buf_off] > 'z') {
      return 1;
    }
    add_char(buf[buf_off], &rep_count, char_counts);
  }

  for (int i = 0;; i++) {
    if (rep_count == 0) {
      printf("%d", i + MARKER_WIDTH);
      return 0;
    }

    buf_off++;
    buf_off %= MARKER_WIDTH;
    rem_char(buf[buf_off], &rep_count, char_counts);
    buf[buf_off] = fgetc(f);
    if ('a' > buf[buf_off] || buf[buf_off] > 'z') {
      return 1;
    }
    add_char(buf[buf_off], &rep_count, char_counts);
  }
}
