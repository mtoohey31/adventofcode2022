let
  inherit (builtins) add filter foldl' fromJSON isString readFile split;
  splitString = sep: s: filter isString (split sep s);
  max = foldl' (max: n: if max > n then max else n) (-1);
  sum = foldl' add 0;

  input = readFile ../input;
  inventoryStrings = splitString "\n\n" input;
  inventoryLists = map (i: map (n: fromJSON n) (splitString "\n" i)) inventoryStrings;
  answer = max (map sum inventoryLists);
in
builtins.toString answer
