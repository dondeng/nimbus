import ttmath, constants, strformat, sequtils, endians, macros, utils / padding, rlp

# TODO improve

proc intToBigEndian*(value: UInt256): Bytes =
  result = repeat(0.byte, 32)
  for z in 0 ..< 4:
    var temp = value.table[z]
    bigEndian64(result[24 - z * 8].addr, temp.addr)
  
proc bigEndianToInt*(value: Bytes): UInt256 =
  var bytes = value.padLeft(32, 0.byte)
  result = 0.u256
  for z in 0 ..< 4:
    var temp = 0.uint
    bigEndian64(temp.addr, bytes[24 - z * 8].addr)
    result.table[z] = temp

#echo intToBigEndian("32482610168005790164680892356840817100452003984372336767666156211029086934369".u256)

proc unsignedToSigned*(value: UInt256): Int256 =
  0.i256
  # TODO
  # if value <= UINT_255_MAX_INT:
  #   return value
  # else:
  #   return value - UINT_256_CEILING_INT

proc signedToUnsigned*(value: Int256): UInt256 =
  0.u256
  # TODO
  # if value < 0:
  #   return value + UINT_256_CEILING_INT
  # else:
  #   return value

macro ceilXX(ceiling: static[int]): untyped =
  var name = ident(&"ceil{ceiling}")
  result = quote:
    proc `name`*(value: UInt256): UInt256 =
      var remainder = value mod `ceiling`.u256
      if remainder == 0:
        return value
      else:
        return value + `ceiling`.u256 - remainder


ceilXX(32)
ceilXX(8)
