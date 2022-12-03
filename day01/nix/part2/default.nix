let
  inherit (builtins) foldl' head lessThan sort tail;
  inherit (import ../../../nix/lib.nix) splitString sum readFileTrimmed toInt;
  max3 = foldl'
    (l: n:
      if head l < n
      then sort lessThan (tail l) ++ [ n ]
      else l)
    [ (-1) (-1) (-1) ];

  input = readFileTrimmed ../../input;
  inventoryStrings = splitString "\n\n" input;
  inventoryLists = map (i: map toInt (splitString "\n" i)) inventoryStrings;
  answer = sum (max3 (map sum inventoryLists));
in
builtins.toString answer
