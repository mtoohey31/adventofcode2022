let
  inherit (builtins) add div head length listToAttrs mapAttrs mul sub tail;
  inherit (import ../../../nix/lib.nix) splitString readFileTrimmed toInt;

  toExpr = s:
    let parts = splitString " " s; in
    assert length parts == 1 || length parts == 3;
    if length parts == 1 then { value = toInt (head parts); }
    else {
      lhsName = head parts;
      op = {
        "+" = add;
        "-" = sub;
        "*" = mul;
        "/" = div;
      }.${head (tail parts)};
      rhsName = head (tail (tail parts));
    };
  toStmt = s:
    let
      parts = splitString ": " s;
    in
    assert length parts == 2; {
      name = head parts;
      value = toExpr (head (tail parts));
    };

  input = readFileTrimmed ../../input;
  stmts = listToAttrs (map toStmt (splitString "\n" input));
  numbers = mapAttrs
    (_: expr:
      if expr ? "value" then expr.value
      else expr.op numbers.${expr.lhsName} numbers.${expr.rhsName}
    )
    stmts;
  answer = numbers.root;
in
builtins.toString answer
