#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define SLICE_NAME dir_slice
#define SLICE_TYPE struct dir
#include "slice.h"

#undef SLICE_NAME
#undef SLICE_TYPE
#define SLICE_NAME file_slice
#define SLICE_TYPE struct file
#include "slice.h"

struct file {
  char* name;
  ulong size;
};

struct dir {
  char* name;
  struct dir *parent;
  struct file_slice files;
  struct dir_slice sub_dirs;
};

struct dir dir_new(char* name, struct dir* parent) {
  struct dir nd;
  nd.name = name;
  nd.parent = parent;
  nd.files = file_slice_new();
  nd.sub_dirs = dir_slice_new();
  return nd;
}

void dir_slice_append(struct dir_slice* s, struct dir d) {
  if (s->len == s->cap) {
    if (s->cap == 0) {
      s-> len = (s->cap = 1);
      s->ptr = malloc(sizeof(struct dir));
      *s->ptr = d;
      return;
    }

    s->cap *= 2;
    struct dir* new_ptr = malloc(sizeof(struct dir) * s->cap);
    memcpy(new_ptr, s->ptr, sizeof(struct dir) * s->len);
    free(s->ptr);
    s->ptr = new_ptr;
  }

  s->ptr[s->len++] = d;
}

void file_slice_append(struct file_slice* s, struct file f) {
  if (s->len == s->cap) {
    if (s->cap == 0) {
      s-> len = (s->cap = 1);
      s->ptr = malloc(sizeof(struct file));
      *s->ptr = f;
      return;
    }

    s->cap *= 2;
    struct file* new_ptr = malloc(sizeof(struct file) * s->cap);
    memcpy(new_ptr, s->ptr, sizeof(struct file) * s->len);
    free(s->ptr);
    s->ptr = new_ptr;
  }

  s->ptr[s->len++] = f;
}

struct result {
  ulong size, answer;
};

ulong dir_size(struct dir d) {
  ulong current_size = 0;
  for (int i = 0; i < d.files.len; i++) {
    current_size += d.files.ptr[i].size;
  }
  for (int i = 0; i < d.sub_dirs.len; i++) {
    current_size += dir_size(d.sub_dirs.ptr[i]);
  }
  return current_size;
}

struct result answer(struct dir d, ulong min) {
  struct result res;
  res.size = 0;
  res.answer = (ulong) -1;

  for (int i = 0; i < d.files.len; i++) {
    res.size += d.files.ptr[i].size;
  }

  for (int i = 0; i < d.sub_dirs.len; i++) {
    struct result p = answer(d.sub_dirs.ptr[i], min);
    res.size += p.size;
    if (res.answer >= p.answer) res.answer = p.answer;
  }

  if (res.size >= min && res.answer >= res.size)
    res.answer = res.size;

  return res;
}

char* fgetsnn(char* s, int n, FILE* f) {
  char* res = fgets(s, n, f);
  char* nl;
  if (res && (nl = strchr(s, '\n'))) *nl = '\0';
  return res;
}

int main() {
  FILE* f = fopen("../../input", "r");
  if (f == NULL) {
    perror("fopen");
    return 1;
  }

  struct dir root = dir_new("/", NULL);
  struct dir* curr = &root;

  char buf[64];
  if (!fgetsnn(buf, 64, f) || strcmp(buf, "$ cd /") != 0) {
    fprintf(stderr, "unexpected first line of input\n");
    return 1;
  }

  while (1) {
    if (strncmp("cd", buf + 2, 2) == 0) {
      char* dest = buf + 5;

      if (strcmp(dest, "/") == 0) {
        curr = &root;
        goto READ;
      }

      if (strcmp(dest, "..") == 0) {
        curr = curr->parent;
        goto READ;
      }

      for (int i = 0; i < curr->sub_dirs.len; i++) {
        if (strcmp(dest, curr->sub_dirs.ptr[i].name) == 0) {
          curr = curr->sub_dirs.ptr + i;
          goto READ;
        }
      }

      dir_slice_append(&curr->sub_dirs, dir_new(strdup(dest), curr));
      curr = curr->sub_dirs.ptr + (curr->sub_dirs.len - 1);

READ:
      if (!fgetsnn(buf, 64, f)) {
        goto END;
      }
    } else if (strncmp("ls", buf + 2, 2) == 0) {
      while (1) {
        if (!fgetsnn(buf, 64, f)) {
          goto END;
        }
        if (buf[0] == '$') {
          break;
        }

        char* spc = strchr(buf, ' ');
        *spc = '\0';

        if (strcmp(buf, "dir") == 0) {
          continue;
        }

        struct file nf;
        nf.name = strdup(spc + 1);
        nf.size = atoi(buf);

        file_slice_append(&curr->files, nf);
      }
    } else {
      fprintf(stderr, "unrecognized command '%s'\n", buf);
      return 1;
    }
  }

END:;
  struct result res = answer(root, 30000000 - (70000000 - dir_size(root)));
  printf("%ld", res.answer);
}
