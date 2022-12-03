let
  inherit (builtins) elemAt;
  inherit (import ../../../nix/lib.nix) splitString sum readFileTrimmed;

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

  input = readFileTrimmed ../../input;
  scores = map
    (l:
      let shape = elemAt (splitString " " l) 1;
      in winScore.${l} + shapeScore."${shape}")
    (splitString "\n" input);
  answer = sum scores;
in
builtins.toString answer
