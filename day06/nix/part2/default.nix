let
  inherit (builtins) attrNames filter head length stringLength substring;
  inherit (import ../../../nix/lib.nix) readFileTrimmed seq stringToSet;

  input = readFileTrimmed ../../input;
  answer = head
    (filter
      (i: length (attrNames (stringToSet (substring i 14 input))) == 14)
      (seq 0 ((stringLength input) - 14))) + 14;
in
builtins.toString answer
