let
  inherit (builtins) add filter foldl' fromJSON head isString match readFile
    split stringLength substring;
in
rec {
  attrOf = s: a: s.${a};

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
}
