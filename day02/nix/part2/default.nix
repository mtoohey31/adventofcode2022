let
  inherit (builtins) elemAt;
  inherit (import ../../../nix/lib.nix) splitString sum readFileTrimmed;

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

  input = readFileTrimmed ../../input;
  scores = map
    (l:
      let outcome = elemAt (splitString " " l) 1;
      in shapeScore.${l} + winScore."${outcome}")
    (splitString "\n" input);
  answer = sum scores;
in
builtins.toString answer
