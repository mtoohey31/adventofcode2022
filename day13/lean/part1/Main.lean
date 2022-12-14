import Lean.Data.Json.Parser

open Lean

partial def cmp (a : Json) (b : Json) : Option Bool := match a with
  | .arr aa => match b with
    | .arr ba => if aa.isEmpty && ba.isEmpty then none
      else if aa.isEmpty || ba.isEmpty then (some aa.isEmpty)
      else match cmp (aa.get! 0) (ba.get! 0) with
        | .some s => some s
        | .none => cmp (.arr (aa.toSubarray 1).toArray) (.arr (ba.toSubarray 1).toArray)
    | .num _ => cmp a (.arr (.singleton b))
    | _ => none
  | .num an => match b with
    | .arr _ => cmp (.arr (.singleton a)) b
    | .num bn => if an == bn then none else some (an < bn)
    | _ => none
  | _ => none

def main : IO Unit := do
  let input <- IO.FS.readFile "../../input"
  let packetPairs := match (input.trimRight.splitOn "\n\n").mapM
    fun s => (s.splitOn "\n").mapM Json.parse with
  | .ok r => r
  | .error e => panic! s!"parsing failed with{e}"
  IO.print $ (packetPairs.enum.map
    fun (i, p) =>
      if (cmp p.head! p.tail!.head!) == some true
      then i + 1 else 0).foldl .add 0
