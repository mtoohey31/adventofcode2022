let
  inherit (builtins) elemAt filter fromJSON head isInt isList length tail
    typeOf;
  inherit (import ../../../nix/lib.nix) readFileTrimmed seq splitString sum;

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

  input = readFileTrimmed ../../input;
  packetPairs = map (pairString: map fromJSON (splitString "\n" pairString))
    (splitString "\n\n" input);
  answer = sum (filter
    (i:
      let pair = elemAt packetPairs (i - 1); in
      assert length pair == 2; cmp (head pair) (head (tail pair)))
    (seq 1 (length packetPairs)));
in
builtins.toString answer
