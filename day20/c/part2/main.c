#include <stdio.h>
#include <stdlib.h>

#define KEY 811589153

struct node {
  struct node *prev;
  struct node *next;
  long long value;
};

int main() {
  FILE *f = fopen("../../input", "r");
  if (f == NULL) {
    perror("fopen");
    return 1;
  }

  // Build linked list
  struct node *head = malloc(sizeof(struct node));
  long long value;
  switch (fscanf(f, "%lld", &value)) {
  case 1:
    break;
  case EOF:
    fprintf(stderr, "invalid input\n");
    return 1;
  default:
    perror("fscanf");
    return 1;
  }
  head->value = value * KEY;

  struct node *prev, *curr;
  prev = head;
  int len = 1;

  int matches;
  while ((matches = fscanf(f, "%lld", &value)) == 1) {
    curr = malloc(sizeof(struct node));
    curr->value = value * KEY;
    curr->prev = prev;
    prev->next = curr;

    prev = curr;
    len++;
  }
  if (matches != EOF) {
    perror("fscanf");
    return 1;
  }
  curr->next = head;
  head->prev = curr;
  curr = head;

  // get pointers to all nodes in the list
  struct node *nodes[len];
  for (int i = 0; i < len; i++) {
    nodes[i] = curr;
    curr = curr->next;
  }

  // move
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < len; j++) {
      curr = nodes[j];
      if (curr->value > 0) {
        // move forward
        for (int k = 0; k < curr->value % (len - 1); k++) {
          curr->next->next->prev = curr;
          curr->prev->next = curr->next;
          curr->next->prev = curr->prev;
          struct node *old_next_next = curr->next->next;
          curr->next->next = curr;
          curr->prev = curr->next;
          curr->next = old_next_next;
        }
      } else if (curr->value < 0) {
        // move backwards
        for (int k = 0; k < (-curr->value) % (len - 1); k++) {
          curr->prev->prev->next = curr;
          curr->next->prev = curr->prev;
          curr->prev->next = curr->next;
          struct node *old_prev_prev = curr->prev->prev;
          curr->prev->prev = curr;
          curr->next = curr->prev;
          curr->prev = old_prev_prev;
        }
      }
    }
  }

  // find zero
  struct node *zero = head;
  while (zero->value != 0) {
    zero = zero->next;
    if (zero == head) {
      fprintf(stderr, "no zero found!\n");
      return 1;
    }
  }

  // find sum
  curr = zero;
  long long sum = 0;
  for (int i = 0; i <= 3000; i++) {
    switch (i) {
    case 1000:
    case 2000:
    case 3000:
      sum += curr->value;
    }
    curr = curr->next;
  }

  printf("%lld", sum);

  return 0;
}
