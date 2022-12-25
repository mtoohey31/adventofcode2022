let
  inherit (builtins) ceil floor stringLength substring;
  inherit (import ../../../nix/lib.nix) splitString sum readFileTrimmed;

  fromSNAFU = s:
    let
      len = stringLength s;
      c = substring (len - 1) 1 s;
      v =
        if c == "2" then 2
        else if c == "1" then 1
        else if c == "0" then 0
        else if c == "-" then -1
        else if c == "=" then -2
        else throw "invalid SNAFU number: unrecognized char " + c;
    in
    if len == 0
    then throw "invalid SNAFU number: zero length"
    else if len == 1
    then v
    else (fromSNAFU (substring 0 (len - 1) s)) * 5 + v;
  pow = base: n: if n > 0 then base * pow base (n - 1) else 1;
  roundLog = base: n:
    let
      n' = n * 1.0;
      d = n' / base;
    in
    if d >= 0.5 || d <= -0.5
    then 1 + roundLog base d
    else 0;
  round = n: if n - floor n >= 0.5 then ceil n else floor n;
  _toSNAFU = n: p: assert (p < 0) -> (n == 0);
    let
      f = pow 5 p;
      v = round ((n * 1.0) / f);
      vc =
        if v == 2 then "2"
        else if v == 1 then "1"
        else if v == 0 then "0"
        else if v == -1 then "-"
        else if v == -2 then "="
        else throw "invalid v " + (toString v);
      d = n - (v * f);
    in
    if p < 0 then "" else vc + _toSNAFU d (p - 1);
  toSNAFU = n: _toSNAFU n (roundLog 5 n);

  input = readFileTrimmed ../../input;
  answer = toSNAFU (sum (map fromSNAFU (splitString "\n" input)));
in
builtins.toString answer
