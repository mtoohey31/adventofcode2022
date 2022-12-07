#include <stdlib.h>

#ifndef SLICE_NAME
#define SLICE_NAME int_slice
#endif

#ifndef SLICE_TYPE
#define SLICE_TYPE int
#endif

#define MAKE_SLICE_NAME(x, y) x##y

struct SLICE_NAME {
  int len, cap;
  SLICE_TYPE* ptr;
};

#define MAKE_SLICE_NEW_NAME(x) MAKE_SLICE_NAME(x, _new)
inline struct SLICE_NAME MAKE_SLICE_NEW_NAME(SLICE_NAME)() {
  struct SLICE_NAME  s;
  s.len = (s.cap = 0);
  s.ptr = NULL;
  return s;
}
