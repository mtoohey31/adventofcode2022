let
  inherit (builtins) add attrNames filter foldl' head intersectAttrs isString length readFile split stringLength substring;
  splitString = sep: s: filter isString (split sep s);
  sum = foldl' add 0;
  stringToSet' = s: a: if stringLength s == 0 then a else
  let
    c = substring 0 1 s;
    sx = substring 1 (stringLength s) s;
  in
  stringToSet' sx (a // { ${c} = null; });
  stringToSet = s: stringToSet' s { };

  priority = {
    a = 1;
    b = 2;
    c = 3;
    d = 4;
    e = 5;
    f = 6;
    g = 7;
    h = 8;
    i = 9;
    j = 10;
    k = 11;
    l = 12;
    m = 13;
    n = 14;
    o = 15;
    p = 16;
    q = 17;
    r = 18;
    s = 19;
    t = 20;
    u = 21;
    v = 22;
    w = 23;
    x = 24;
    y = 25;
    z = 26;

    A = 27;
    B = 28;
    C = 29;
    D = 30;
    E = 31;
    F = 32;
    G = 33;
    H = 34;
    I = 35;
    J = 36;
    K = 37;
    L = 38;
    M = 39;
    N = 40;
    O = 41;
    P = 42;
    Q = 43;
    R = 44;
    S = 45;
    T = 46;
    U = 47;
    V = 48;
    W = 49;
    X = 50;
    Y = 51;
    Z = 52;
  };

  input = readFile ../input;
  rucksacks = splitString "\n" input;
  duplicates = map
    (r:
      let
        len = stringLength r;
        firstHalf = substring 0 (len / 2) r;
        firstHalfSet = stringToSet firstHalf;
        secondHalf = substring (len / 2) len r;
        secondHalfSet = stringToSet secondHalf;
        inter = intersectAttrs firstHalfSet secondHalfSet;
        interNames = attrNames inter;
      in
      if length interNames != 1
      then throw r
      else head interNames
    )
    rucksacks;
  answer = sum (map (d: priority.${d}) duplicates);
in
builtins.toString answer
