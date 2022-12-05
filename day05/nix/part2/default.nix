let
  inherit (builtins) concatStringsSep elemAt head filter foldl' isList length
    split stringLength substring tail;
  inherit (import ../../../nix/lib.nix) drop splitString readFileTrimmed seq
    take toInt updateList;

  toMove = s:
    let
      matchLists = filter isList
        (split "move ([[:digit:]]+) from ([[:digit:]]+) to ([[:digit:]]+)" s);
      matches = assert length matchLists == 1; head matchLists;
    in
    assert length matches == 3; {
      count = toInt (head matches);
      from = toInt (head (tail matches));
      to = toInt (head (tail (tail matches)));
    };
  toStacks = s:
    let lines = splitString "\n" s; in
    map
      (i: filter (c: c != " ")
        (map
          (j: substring ((i * 4) + 1) 1 (elemAt lines j))
          (seq 0 ((length lines) - 2)))
      )
      (seq 0 ((((stringLength (head lines)) + 1) / 4) - 1));

  input = readFileTrimmed ../../input;
  parts = splitString "\n\n" input;
  startingStacksString = assert length parts == 2; head parts;
  procedureString = head (tail parts);

  startingStacks = toStacks startingStacksString;
  moves = map toMove (splitString "\n" procedureString);

  finalStacks = foldl'
    (stacks: move:
      let
        fromStack = elemAt stacks (move.from - 1);
        fromAfter = drop move.count fromStack;
        toStack = elemAt stacks (move.to - 1);
        moved = take move.count fromStack;
        toAfter = moved ++ toStack;

        stacksWithNewFrom = updateList stacks fromAfter (move.from - 1);
      in
      updateList stacksWithNewFrom toAfter (move.to - 1)
    )
    startingStacks
    moves;

  answer = concatStringsSep "" (map head finalStacks);
in
builtins.toString answer
