let
  inherit (builtins) add filter foldl' fromJSON head isString length match
    readFile split stringLength substring tail;
in
rec {
  attrOf = s: a: s.${a};

  drop = n: l: if n > 0 then (drop (n - 1) (tail l)) else l;

  max = foldl' (max: n: if max == null || max < n then n else max) null;

  readFileTrimmed = p:
    let
      body = readFile p;
      bodyLength = stringLength body;
      trailingWhitespace = match ".*[^[:space:]]+([[:space:]]*$)" body;
      trailingLength = stringLength
        (if trailingWhitespace == [ ]
        then "" else head trailingWhitespace);
    in
    substring 0 (bodyLength - trailingLength) body;

  repeat = e: n: if n == 0 then [ ] else [ e ] ++ (repeat e (n - 1));

  rev = l: if length l > 0 then (rev (tail l)) ++ [ (head l) ] else [ ];

  # inclusive
  seq = min: max: if min <= max then [ min ] ++ (seq (min + 1) max) else [ ];

  # inclusive
  take = n: l: if n == 0 then [ ] else [ (head l) ] ++ (take (n - 1) (tail l));

  splitString = sep: s: filter isString (split sep s);

  _stringToSet = s: a: if stringLength s == 0 then a else
  let
    c = substring 0 1 s;
    sx = substring 1 (stringLength s) s;
  in
  _stringToSet sx (a // { ${c} = null; });
  stringToSet = s: _stringToSet s { };

  sum = foldl' add 0;

  toInt = fromJSON;

  _updateList = l: v: i:
    if i == 0 then [ v ] ++ (tail l)
    else [ (head l) ] ++ (_updateList (tail l) v (i - 1));
  updateList = l: v: i: assert i < length l; _updateList l v i;
}
