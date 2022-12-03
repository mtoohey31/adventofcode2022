let
  inherit (builtins) add elemAt filter foldl' isString readFile split;
  splitString = sep: s: filter isString (split sep s);
  sum = foldl' add 0;

  winScore = {
    X = 0;
    Y = 3;
    Z = 6;
  };
  shapeScore = {
    "A X" = 3;
    "A Y" = 1;
    "A Z" = 2;

    "B X" = 1;
    "B Y" = 2;
    "B Z" = 3;

    "C X" = 2;
    "C Y" = 3;
    "C Z" = 1;
  };

  input = readFile ../../input;
  scores = map (l: shapeScore.${l} + winScore."${(elemAt (splitString " " l) 1)}") (splitString "\n" input);
  answer = sum scores;
in
builtins.toString answer
