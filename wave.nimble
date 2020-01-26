# Package

version       = "1.0.0"
author        = "jiro4989"
description   = "wave is a tiny WAV sound module"
license       = "MIT"
srcDir        = "src"



# Dependencies

requires "nim >= 1.0.4"

task docs, "Generate API documents":
  exec "nimble doc --index:on --project --out:docs --hints:off src/wave.nim"

