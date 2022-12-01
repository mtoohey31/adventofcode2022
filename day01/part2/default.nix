let
  inherit (builtins) add elemAt filter foldl' fromJSON isString lessThan readFile sort split;
  splitString = sep: s: filter isString (split sep s);
  max3 = foldl'
    (l: n:
      if elemAt l 0 < n
      then sort lessThan [ n (elemAt l 1) (elemAt l 2) ]
      else l)
    [ (-1) (-1) (-1) ];
  sum = foldl' add 0;

  input = readFile ../input;
  inventoryStrings = splitString "\n\n" input;
  inventoryLists = map (i: map (n: fromJSON n) (splitString "\n" i)) inventoryStrings;
  answer = sum (max3 (map sum inventoryLists));
in
builtins.toString answer
