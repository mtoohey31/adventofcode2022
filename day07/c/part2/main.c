#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct dir_slice {
  int len;
  struct dir* ptr;
};

struct file_slice {
  int len;
  struct file* ptr;
};

struct file {
  char* name;
  long size;
};

struct dir {
  char* name;
  struct dir *parent;
  struct file_slice files;
  struct dir_slice sub_dirs;
};

struct dir_slice dir_slice_append(struct dir_slice s, struct dir d) {
  struct dir_slice ns;
  ns.len = s.len + 1;
  ns.ptr = malloc(sizeof(struct dir) * ns.len);
  memcpy(ns.ptr, s.ptr, sizeof(struct dir) * s.len);
  if (s.len != 0) {
    free(s.ptr);
  }
  ns.ptr[s.len] = d;
  return ns;
}

struct file_slice file_slice_append(struct file_slice s, struct file f) {
  struct file_slice ns;
  ns.len = s.len + 1;
  ns.ptr = malloc(sizeof(struct file) * ns.len);
  memcpy(ns.ptr, s.ptr, sizeof(struct file) * s.len);
  if (s.len != 0) {
    free(s.ptr);
  }
  ns.ptr[s.len] = f;
  return ns;
}

long dir_size(struct dir d) {
  long current_size = 0;
  for (int i = 0; i < d.files.len; i++) {
    current_size += d.files.ptr[i].size;
  }
  for (int i = 0; i < d.sub_dirs.len; i++) {
    current_size += dir_size(d.sub_dirs.ptr[i]);
  }
  return current_size;
}

long smallest_big_enough(struct dir d, long min, long* answer) {
  long current_size = 0;
  for (int i = 0; i < d.files.len; i++) {
    current_size += d.files.ptr[i].size;
  }
  for (int i = 0; i < d.sub_dirs.len; i++) {
    current_size += smallest_big_enough(d.sub_dirs.ptr[i], min, answer);
  }
  if (current_size >= min && *answer >= current_size) {
    *answer = current_size;
  }
  return current_size;
}

int main() {
  FILE* f = fopen("../../input", "r");
  if (f == NULL) {
    perror("fopen");
    return 1;
  }

  struct dir root;
  root.files.len = 0;
  root.sub_dirs.len = 0;
  root.parent = NULL;

  struct dir* curr = &root;

  char buf[64];
  if (!fgets(buf, 64, f)) {
    fprintf(stderr, "first line of input was not a command\n");
    return 1;
  }

  while (1) {
    char* nl;
    if (!(nl = strchr(buf, '\n'))) {
      fprintf(stderr, "buffer overflow\n");
      return 1;
    }
    *nl = '\0';

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

      struct dir nd;
      nd.files.len = 0;
      nd.sub_dirs.len = 0;
      nd.name = strdup(dest);
      nd.parent = curr;

      curr->sub_dirs = dir_slice_append(curr->sub_dirs, nd);
      curr = curr->sub_dirs.ptr + (curr->sub_dirs.len - 1);

READ:
      if (!fgets(buf, 64, f)) {
        goto END;
      }
    } else if (strncmp("ls", buf + 2, 2) == 0) {
      while (1) {
        if (!fgets(buf, 64, f)) {
          goto END;
        }
        if (buf[0] == '$') {
          break;
        }

        char* nl;
        if (!(nl = strchr(buf, '\n'))) {
          fprintf(stderr, "buffer overflow\n");
          return 1;
        }
        *nl = '\0';

        char* spc = strchr(buf, ' ');
        *spc = '\0';

        if (strcmp(buf, "dir") == 0) {
          continue;
        }

        struct file nf;
        nf.name = strdup(spc + 1);
        nf.size = atoi(buf);

        curr->files = file_slice_append(curr->files, nf);
      }
    } else {
      fprintf(stderr, "unrecognized command '%s'\n", buf);
      return 1;
    }
  }

END:;
  long root_size = dir_size(root);
  long answer = root_size;
  smallest_big_enough(root, 30000000 - (70000000 - root_size), &answer);
  printf("%ld", answer);
}
