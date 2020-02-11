import wavetypes
export wavetypes

type
  WaveWrite* = ref object
    ## WaveWrite is a Wave object of `fmWrite` mode.
    ## WaveWrite doesn't have a reading functions.
    fileName: string
    riffChunkDescriptor: RIFFChunkDescriptor
    formatSubChunk: FormatSubChunk
    dataSubChunk: DataSubChunk

proc patchByteRate(self: WaveWrite) =
  let fmt = self.formatSubChunk
  let byteRate = fmt.sampleRate * fmt.numChannels * fmt.bitsPerSample div fmt.bitsPerSample
  self.formatSubChunk.byteRate = byteRate

proc patchBlockAlign(self: WaveWrite) =
  let fmt = self.formatSubChunk
  let blockAlign = fmt.numChannels * fmt.bitsPerSample div fmt.bitsPerSample
  self.formatSubChunk.blockAlign = blockAlign

proc `numChannels=`*(self: WaveWrite, numChannels: uint16) =
  self.formatSubChunk.numChannels = numChannels
  self.patchByteRate()
  self.patchBlockAlign()

proc `sampleRate=`*(self: WaveWrite, sampleRate: uint16) =
  self.formatSubChunk.sampleRate = sampleRate
  self.patchByteRate()

proc writeFrames*(self: WaveWrite, data: openArray[byte]) =
  self.dataSubChunk.size += data.len.uint32
  # Riff header + formatchunk + datachunk
  self.riffChunkDescriptor.size = 4'u32 + 24'u32 + 8'u32 + self.dataSubChunk.size
  for b in data:
    self.dataSubChunk.data.write(b)


proc openWaveWriteFile*(fileName: string): WaveWrite =
  ## Opens `file` and returns `WaveWrite <#WaveWrite>`_ object.
  ## Last, you must `close <#close,WaveWrite>`_ `WaveWrite <#WaveWrite>`_ object.
  result = WaveWrite()
  result.fileName = fileName
  result.riffChunkDescriptor = newRIFFChunkDescriptor([])
  result.formatSubChunk = newFormatSubChunk(
    format=WAVE_FORMAT_PCM,
    numChannels=0'u16,
    sampleRate=0'u32,
    byteRate=0'u32,
    blockAlign=0'u16,
    bitsPerSample=8'u16,
  )
  result.dataSubChunk = newDataSubChunk()

proc close*(self: WaveWrite) =
  let head = self.riffChunkDescriptor
  let fmt = self.formatSubChunk

  if fmt.numChannels == 0: raise newException(WaveFormatSubChunkError, "'numChannels' is not set")
  if fmt.sampleRate == 0: raise newException(WaveFormatSubChunkError, "'sampleRate' is not set")
  if fmt.byteRate == 0: raise newException(WaveFormatSubChunkError, "'byteRate' is not set")
  if fmt.blockAlign == 0: raise newException(WaveFormatSubChunkError, "'blockAlign' is not set")
  if self.dataSubChunk.size == 0: raise newException(WaveDataIsEmptyError, "frames are not set")

  var outFile = newFileStream(self.fileName, fmWrite)
  # RIFF header
  outFile.write(head.id)
  outFile.write(head.size)
  outFile.write(head.format)

  # Format chunk
  outFile.write(fmt.id)
  outFile.write(fmt.size)
  outFile.write(fmt.format)
  outFile.write(fmt.numChannels)
  outFile.write(fmt.sampleRate)
  outFile.write(fmt.byteRate)
  outFile.write(fmt.blockAlign)
  outFile.write(fmt.bitsPerSample)

  # Data chunk
  outFile.write(self.dataSubChunk.id)
  outFile.write(self.dataSubChunk.size)

  self.dataSubChunk.data.setPosition(0)
  const bufSize = 1024
  var buffer: array[bufSize, byte]
  while true:
    let writtenSize = self.dataSubChunk.data.readData(addr(buffer), bufSize)
    if writtenSize == bufSize:
      outFile.write(buffer)
    elif 0 < writtenSize:
      for i in 0..<writtenSize:
        outFile.write(buffer[i])
    else:
      if self.dataSubChunk.data.atEnd:
        break

  outFile.close()
  self.dataSubChunk.data.close()

proc `$`*(self: WaveWrite): string = $self[]
