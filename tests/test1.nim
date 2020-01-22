import unittest

include wave

import streams

test "write file test":
  var strm = newFileStream("out.dat", fmWrite)
  strm.write("RIFF")
  strm.write(120'u32)
  strm.write("WAVE")
  strm.close()

test "parseWaveFile":
  parseWaveFile("tests/testdata/simple.wav")
