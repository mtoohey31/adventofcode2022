let
  inherit (builtins) elem elemAt filter fromJSON head isInt isList length
    sort stringLength tail typeOf;
  inherit (import ../../../nix/lib.nix) readFileTrimmed seq splitString;

  cmp = a: b:
    if isInt a && isList b then cmp [ a ] b
    else if isList a && isInt b then cmp a [ b ]
    else if isInt a && isInt b then
      if a == b then null else a < b
    else if isList a && isList b then
      if a == [ ] && b == [ ] then null
      else if a == [ ] || b == [ ] then a == [ ]
      else
        let
          headCmp = cmp (head a) (head b);
        in
        if headCmp != null then headCmp
        else cmp (tail a) (tail b)
    else throw "unexpected types a: " ++ (typeOf a) ++ ", b: " ++ (typeOf b);
  dividers = [ [ [ 2 ] ] [ [ 6 ] ] ];

  input = readFileTrimmed ../../input;
  packetPairs = map fromJSON
    (filter (s: stringLength s != 0) (splitString "\n" input));
  sorted = sort cmp (packetPairs ++ dividers);
  divIdxs = filter (i: elem (elemAt sorted (i - 1)) dividers) (seq 1 (length sorted));
  answer = assert length divIdxs == 2; (head divIdxs) * (head (tail (divIdxs)));
in
builtins.toString answer
