let
  inherit (import ../../../nix/lib.nix) max splitString sum readFileTrimmed
    toInt;

  input = readFileTrimmed ../../input;
  inventoryStrings = splitString "\n\n" input;
  inventoryLists = map (i: map toInt (splitString "\n" i)) inventoryStrings;
  answer = max (map sum inventoryLists);
in
builtins.toString answer
