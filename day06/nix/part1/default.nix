let
  inherit (builtins) attrNames filter head length stringLength substring;
  inherit (import ../../../nix/lib.nix) readFileTrimmed seq stringToSet;

  input = readFileTrimmed ../../input;
  answer = head
    (filter
      (i: length (attrNames (stringToSet (substring i 4 input))) == 4)
      (seq 0 ((stringLength input) - 4))) + 4;
in
builtins.toString answer
