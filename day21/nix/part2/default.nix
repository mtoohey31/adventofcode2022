let
  inherit (builtins) add div head length listToAttrs mapAttrs mul sub tail;
  inherit (import ../../../nix/lib.nix) splitString readFileTrimmed toInt;

  toExpr = s:
    let parts = splitString " " s; in
    assert length parts == 1 || length parts == 3;
    if length parts == 1 then { value = toInt (head parts); }
    else
      let opString = head (tail parts); in {
        lhsName = head parts;
        op = {
          "+" = add;
          "-" = sub;
          "*" = mul;
          "/" = div;
        }.${opString};
        opComm = {
          "+" = true;
          "-" = false;
          "*" = true;
          "/" = false;
        }.${opString};
        invOp = {
          "+" = sub;
          "-" = add;
          "*" = div;
          "/" = mul;
        }.${opString};
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
  stmtList = map toStmt (splitString "\n" input);
  stmts = listToAttrs stmtList;

  fixed = mapAttrs
    (name: expr:
      if name == "humn" then null
      else if expr ? "value" then expr.value
      else
        let
          lhs = fixed.${expr.lhsName};
          rhs = fixed.${expr.rhsName};
        in
        if lhs == null || rhs == null then null
        else expr.op lhs rhs
    )
    stmts;

  rootExpr = stmts.root;
  rootFixed =
    if fixed.${rootExpr.lhsName} != null
    then fixed.${rootExpr.lhsName} else fixed.${rootExpr.rhsName};
  rootSolvedName =
    if rootFixed == rootExpr.lhsName
    then rootExpr.rhsName else rootExpr.lhsName;

  solved = listToAttrs
    (map
      ({ name, value }:
        if fixed.${name} != null || name == "root" || name == "humn"
        then { inherit name; value = null; }
        else
          with value;
          let
            lhs = fixed.${lhsName};
            rhs = fixed.${rhsName};
            inherit (assert (lhs == null) != (rhs == null);
            if lhs != null then {
              known = lhs;
              unknownName = rhsName;
            } else {
              known = rhs;
              unknownName = lhsName;
            }) known unknownName;
          in
          {
            name = unknownName;
            value =
              if opComm || known != lhs
              then invOp solved.${name} known
              else op known solved.${name};
          }
      )
      stmtList) // { ${rootSolvedName} = rootFixed; };

  answer = solved.humn;
in
builtins.toString answer
