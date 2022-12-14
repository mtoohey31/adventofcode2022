import Lean.Data.Json.Parser

open Lean

def dividers := [Json.arr [.num 2].toArray, Json.arr [.num 6].toArray]

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
  let packets := match ((input.trimRight.splitOn "\n").filter
    fun s => !s.isEmpty).mapM Json.parse with
  | .ok r => r
  | .error e => panic! s!"parsing failed with{e}"
  IO.print $ (((packets ++ dividers).toArray.qsort
    fun a b => (cmp a b).getD true).toList.enum.filterMap
    fun (i, p) => if dividers.contains p
      then some (i + 1) else none).foldl .mul 1
