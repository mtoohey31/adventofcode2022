import std/options
from std/strscans import scanf
from std/strutils import parseInt, split, startsWith
from std/sequtils import apply, map
from std/algorithm import sort
from sugar import `=>`

type
  Monkey = ref object
    items: seq[int]
    operation: proc(worry: int): int
    testDivisor: int
    passTarget, failTarget: int
    inspected: int

let f = open("../../input")

var monkeys: seq[Monkey]

while true:
  try:
    let numberLine = f.readLine()
    if numberLine == "":
      continue
    var monkeyNumber: int
    if not scanf(numberLine, "Monkey $i:", monkeyNumber) and monkeyNumber == len(monkeys):
      raise newException(ValueError, "invalid input: " & numberLine)
  except EOFError:
    break

  let monkey = Monkey()

  let itemsLine = f.readLine()
  if not itemsLine.startsWith("  Starting items: "):
      raise newException(ValueError, "invalid input: " & itemsLine)
  monkey.items = itemsLine[len("  Starting items: ")..len(itemsLine) - 1]
    .split(", ").map(parseInt)

  let operationLine = f.readLine()
  var operationChar: char
  var operationValue: int
  let operationValueOption = if scanf(operationLine, "  Operation: new = old $c $i", operationChar, operationValue):
    some(operationValue)
  elif scanf(operationLine, "  Operation: new = old $c old", operationChar):
    none(int)
  else:
    raise newException(ValueError, "invalid input: " & operationLine)
  closureScope:
    let operator =
      case operationChar
      of '+': (x, y: int) => x + y
      of '*': (x, y: int) => x * y
      else: raise newException(ValueError, "unexpected operator: " & operationChar)
    if operationValueOption.isSome():
      let value = operationValueOption.get()
      monkey.operation = (worry: int) => operator(worry, value)
    else:
      monkey.operation = (worry: int) => operator(worry, worry)

  let testLine = f.readLine()
  if not scanf(testLine, "  Test: divisible by $i", monkey.testDivisor):
    raise newException(ValueError, "invalid input: " & testLine)

  let (passTargetLine, failTargetLine) = (f.readLine(), f.readLine())
  if not scanf(passTargetLine, "    If true: throw to monkey $i", monkey.passTarget):
    raise newException(ValueError, "invalid input: " & passTargetLine)
  if not scanf(failTargetLine, "    If false: throw to monkey $i", monkey.failTarget):
    raise newException(ValueError, "invalid input: " & failTargetLine)

  monkeys.add(monkey)

for i in countup(1, 20):
  for monkey in monkeys:
    apply(monkey.items, (worry: int) => monkey.operation(worry) div 3)
    for item in monkey.items:
      monkeys[
        if item mod monkey.testDivisor == 0: monkey.passTarget
        else: monkey.failTarget
      ].items.add(item)
      inc monkey.inspected
    monkey.items = @[]

monkeys.sort((a, b: Monkey) => cmp(b.inspected, a.inspected))
stdout.write(monkeys[0].inspected * monkeys[1].inspected)
