let
  inherit (builtins) head filter length tail;
  inherit (import ../../../nix/lib.nix) splitString readFileTrimmed toInt;

  toRange = s:
    let parts = splitString "-" s; in
    assert length parts == 2; {
      start = toInt (head parts);
      end = toInt (head (tail parts));
    };
  toRangePair = s:
    let parts = splitString "," s;
    in assert length parts == 2; {
      a = toRange (head parts);
      b = toRange (head (tail parts));
    };

  input = readFileTrimmed ../../input;
  answer = length (filter
    (l: with toRangePair l;
    (b.start <= a.start && a.start <= b.end) ||
    (b.start <= a.end && a.end <= b.end) ||
    (a.start <= b.start && b.end <= a.end) ||
    (b.start <= a.start && a.end <= b.end))
    (splitString "\n" input));
in
builtins.toString answer
