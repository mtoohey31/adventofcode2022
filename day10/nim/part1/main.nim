import std/options
from std/strutils import parseInt

let f = open("../../input")

var
  addxVal = none(int)
  cycle = 0
  x = 1
  strengthSum = 0

while true:
  inc cycle
  case cycle
  of 20, 60, 100, 140, 180, 220:
    strengthSum += cycle * x
  else: discard

  if addxVal.isSome:
    x += addxVal.get()
    addxVal = none(int)
    continue

  var line: string
  try:
    line = f.readLine()
  except EOFError:
    break

  var space = line.find(' ')
  if space == -1:
    space = len(line)
  case line[0..space-1]
  of "addx":
    addxVal = some(parseInt(line[space+1..len(line)-1]))
  of "noop": discard
  else:
    raise newException(ValueError, "unexpected instruction")

stdout.write(strengthSum)
