# Nimbus
# Copyright (c) 2018 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# ##################################################################
# Macros to facilitate opcode procs creation

import
  macros, strformat, stint, eth_common,
  ../../computation, ../../stack, ../../code_stream,
  ../../../constants, ../../../vm_types, ../../memory,
  ../../../errors, ../../message, ../../interpreter/[gas_meter, opcode_values],
  ../../interpreter/utils/utils_numeric

proc pop(tree: var NimNode): NimNode =
  ## Returns the last value of a NimNode and remove it
  result = tree[tree.len-1]
  tree.del(tree.len-1)

macro op*(procname: untyped, inline: static[bool], stackParams_body: varargs[untyped]): untyped =
  ## Usage:
  ## .. code-block:: nim
  ##   op add, inline = true, lhs, rhs:
  ##     push:
  ##       lhs + rhs

  # TODO: Unfortunately due to varargs[untyped] consuming all following parameters,
  # we can't have a nicer macro signature `stackParams: varargs[untyped], body: untyped`
  # see https://github.com/nim-lang/Nim/issues/5855 and are forced to "pop"

  let computation = newIdentNode("computation")
  var stackParams = stackParams_body

  # 1. Separate stackParams and body with pop
  let body = newStmtList().add stackParams.pop

  # 3. let (x, y, z) = computation.stack.popInt(3)
  let len = stackParams.len
  var popStackStmt = nnkVarTuple.newTree()

  if len != 0:
    for params in stackParams:
      popStackStmt.add newIdentNode(params.ident)

    popStackStmt.add newEmptyNode()
    popStackStmt.add quote do:
      `computation`.stack.popInt(`len`)

    popStackStmt = nnkStmtList.newTree(
      nnkLetSection.newTree(popStackStmt)
    )
  else:
    popStackStmt = nnkDiscardStmt.newTree(newEmptyNode())

  # 4. Generate the proc
  # TODO: replace by func to ensure no side effects
  if inline:
    result = quote do:
      proc `procname`*(`computation`: var BaseComputation) {.inline.} =
        `popStackStmt`
        `body`
  else:
    result = quote do:
      proc `procname`*(`computation`: var BaseComputation) =
        `popStackStmt`
        `body`

macro genPush*(): untyped =
  # TODO: avoid allocating a seq[byte], transforming to a string, stripping char
  func genName(size: int): NimNode = ident(&"push{size}")
  result = newStmtList()

  for size in 1 .. 32:
    let name = genName(size)
    result.add quote do:
      func `name`*(computation: var BaseComputation) {.inline.}=
        ## Push `size`-byte(s) on the stack
        computation.stack.push computation.code.readVmWord(`size`)

macro genDup*(): untyped =
  func genName(position: int): NimNode = ident(&"dup{position}")
  result = newStmtList()

  for pos in 1 .. 16:
    let name = genName(pos)
    result.add quote do:
      func `name`*(computation: var BaseComputation) {.inline.}=
        computation.stack.dup(`pos`)

macro genSwap*(): untyped =
  func genName(position: int): NimNode = ident(&"swap{position}")
  result = newStmtList()

  for pos in 1 .. 16:
    let name = genName(pos)
    result.add quote do:
      func `name`*(computation: var BaseComputation) {.inline.}=
        computation.stack.swap(`pos`)

proc logImpl(c: var BaseComputation, opcode: Op, topicCount: int) =
  assert(topicCount in 0 .. 4)
  let (memStartPosition, size) = c.stack.popInt(2)
  let (memPos, len) = (memStartPosition.cleanMemRef, size.cleanMemRef)

  if memPos < 0 or len < 0:
    raise newException(OutOfBoundsRead, "Out of bounds memory access")

  var log: Log
  log.topics = newSeqOfCap[Topic](topicCount)
  for i in 0 ..< topicCount:
    log.topics.add(c.stack.popTopic())
  c.gasMeter.consumeGas(
    c.gasCosts[opcode].m_handler(c.memory.len, memPos, len),
    reason="Memory expansion, Log topic and data gas cost")

  c.memory.extend(memPos, len)
  log.data = c.memory.read(memPos, len)
  log.address = c.msg.storageAddress
  c.addLogEntry(log)

template genLog*() =
  proc log0*(c: var BaseComputation) {.inline.} = logImpl(c, Log0, 0)
  proc log1*(c: var BaseComputation) {.inline.} = logImpl(c, Log1, 1)
  proc log2*(c: var BaseComputation) {.inline.} = logImpl(c, Log2, 2)
  proc log3*(c: var BaseComputation) {.inline.} = logImpl(c, Log3, 3)
  proc log4*(c: var BaseComputation) {.inline.} = logImpl(c, Log4, 4)
