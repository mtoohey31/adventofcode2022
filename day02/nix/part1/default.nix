let
  inherit (builtins) add elemAt filter foldl' isString readFile split;
  splitString = sep: s: filter isString (split sep s);
  sum = foldl' add 0;

  shapeScore = {
    X = 1;
    Y = 2;
    Z = 3;
  };
  winScore = {
    "A X" = 3;
    "A Y" = 6;
    "A Z" = 0;

    "B X" = 0;
    "B Y" = 3;
    "B Z" = 6;

    "C X" = 6;
    "C Y" = 0;
    "C Z" = 3;
  };

  input = readFile ../../input;
  scores = map (l: winScore.${l} + shapeScore."${(elemAt (splitString " " l) 1)}") (splitString "\n" input);
  answer = sum scores;
in
builtins.toString answer
