import unittest

include wave

import streams

when false:
  test "write file test":
    var strm = newFileStream("out.dat", fmWrite)
    strm.write("RIFF")
    strm.write(120'u32)
    strm.write("WAVE")
    strm.close()

test "create wave with byte":
  var data = @[
    # Riff header
    0x52'u8, 0x49, 0x46, 0x46, # id
    0x74, 0x00, 0x00, 0x00,    # size
    0x57, 0x41, 0x56, 0x45,    # type
    # Format chunk
    0x66, 0x6D, 0x74, 0x20, # id
    0x10, 0x00, 0x00, 0x00, # size
    0x01, 0x00,             # format
    0x01, 0x00,             # channels
    0x40, 0x1F, 0x00, 0x00, # sample rate
    0x40, 0x1F, 0x00, 0x00, # bytepersec
    0x01, 0x00,             # blockalign
    0x08, 0x00,             # bitswidth
    # Data chunk
    0x64, 0x61, 0x74, 0x61, # id
    0x50, 0x00, 0x00, 0x00, # size
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
    0xFF, 0xFF, 0xFF, 0xFF, # data
    0x00, 0x00, 0x00, 0x00, # data
  ]

  var strm = newFileStream("tests/out.wav", fmWrite)
  for b in data:
    strm.write(b)
  strm.close()

test "parseWaveFile":
  parseWaveFile("tests/testdata/simple.wav")
