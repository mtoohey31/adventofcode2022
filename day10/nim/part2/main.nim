import std/options
from std/strutils import parseInt

let f = open("../../input")

const
  width = 40
  height = 6

var
  addxVal = none(int)
  x = 1

for cycle in 1..(width * height):
  let rayX = (cycle - 1) mod width
  stdout.write(
    if abs(rayX - x) <= 1: '#'
    else: '.'
  )
  if rayX == width - 1:
    stdout.write('\n')

  if addxVal.isSome:
    x += addxVal.get()
    addxVal = none(int)
    continue

  var line: string
  line = f.readLine()

  var space = line.find(' ')
  if space == -1:
    space = len(line)
  case line[0..space-1]
  of "addx":
    addxVal = some(parseInt(line[space + 1..len(line) - 1]))
  of "noop": discard
  else:
    raise newException(ValueError, "unexpected instruction")
