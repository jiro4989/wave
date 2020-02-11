import wavetypes
export wavetypes

type
  WaveRead* = ref object
    ## WaveRead is a Wave object of `fmRead` mode.
    ## WaveRead doesn't have a writing functions.
    riffChunkDescriptor: RIFFChunkDescriptor
    formatSubChunk: FormatSubChunk
    dataSubChunk: DataSubChunk
    factSubChunk: FactSubChunk
    audioStartPos: int

template validate(T: typedesc, prefix, want, got, key: string) =
  if want != got:
    let msg = "illegal " & prefix & " " & key & ". (" & key & " = '" & got & "')"
    raise newException(T, msg)

proc parseRIFFChunkDescriptor(strm: Stream): RIFFChunkDescriptor =
  ## 12 byte
  result = RIFFChunkDescriptor()

  result.id = strm.readStr(4)
  validate WaveRIFFChunkDescriptorError, "RIFF Header", riffChunkDescriptorId, result.id, "id"
  result.size = strm.readUint32()
  result.format = strm.readStr(4)
  validate WaveRIFFChunkDescriptorError, "RIFF Header", riffChunkDescriptorType, result.format, "format"

proc parseFormatSubChunk(strm: Stream): FormatSubChunk =
  ## 24 byte
  result = FormatSubChunk()
  result.id = strm.readStr(4)
  validate WaveFormatSubChunkError, "Format chunk", formatSubChunkId, result.id, "id"
  result.size = strm.readUint32()
  result.format = strm.readUint16()
  if result.format != WAVE_FORMAT_PCM:
    raise newException(WaveFormatSubChunkError, "unknown format: " & $result.format)
  result.numChannels = strm.readUint16()
  result.sampleRate = strm.readUint32()
  result.byteRate = strm.readUint32()
  result.blockAlign = strm.readUint16()
  result.bitsPerSample = strm.readUint16()
  if 16'u32 < result.size:
    result.extendedSize = strm.readUint16()
    for i in 0'u16 ..< result.extendedSize:
      result.extended.add(strm.readUint8())

proc parseDataSubChunk(strm: Stream): DataSubChunk =
  result = DataSubChunk()
  result.id = strm.readStr(4)
  validate WaveDataSubChunkError, "Data chunk", dataSubChunkId, result.id, "id"
  result.size = strm.readUint32()
  result.data = strm

proc parseFactSubChunk(strm: Stream): FactSubChunk =
  result = FactSubChunk()
  result.id = strm.readStr(4)
  validate WaveFactSubChunkError, "Fact chunk", factSubChunkId, result.id, "id"
  result.size = strm.readUint32()
  for _ in 0..<result.size:
    result.data.add(strm.readUint8())

proc skipChunk(strm: Stream) =
  discard strm.readStr(4)
  let size = strm.readUint32().int
  discard strm.readStr(size)

proc riffChunkDescriptorSize*(self: WaveRead): uint32 =
  ## Returns a size of `RiffChunkDescriptor <#RiffChunkDescriptor>`_.
  ## It equals `WAV filesize - 8 byte`.
  runnableExamples:
    ## sample1.wav is 124 byte.
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.riffChunkDescriptorSize == 116
    wav.close()

  self.riffChunkDescriptor.size

proc numChannels*(self: WaveRead): uint16 =
  ## Returns a numChannels of `FormatSubChunk <#FormatSubChunk>`_.
  ## You can use `Monaural <#numChannelsMono>`_ or `Stereo <#numChannelsStereo>`_.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.numChannels == numChannelsMono

  self.formatSubChunk.numChannels

proc sampleRate*(self: WaveRead): uint32 =
  ## Returns a sampleRate of `FormatSubChunk <#FormatSubChunk>`_.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.sampleRate == 8000'u32
    wav.close()

  self.formatSubChunk.sampleRate

proc byteRate*(self: WaveRead): uint32 =
  ## Returns a byteRate of `FormatSubChunk <#FormatSubChunk>`_.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.byteRate == 8000'u32
    wav.close()

  self.formatSubChunk.byteRate

proc blockAlign*(self: WaveRead): uint16 =
  ## Returns a blockAlign of `FormatSubChunk <#FormatSubChunk>`_.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.blockAlign == 1'u16
    wav.close()

  self.formatSubChunk.blockAlign

proc bitsPerSample*(self: WaveRead): uint16 =
  ## Returns a bitsPerSample of `FormatSubChunk <#FormatSubChunk>`_.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.bitsPerSample == 8'u16
    wav.close()

  self.formatSubChunk.bitsPerSample

proc dataSubChunkSize*(self: WaveRead): uint32 =
  ## Returns a size of `DataSubChunk <#DataSubChunk>`_.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.dataSubChunkSize == 80'u16
    wav.close()

  self.dataSubChunk.size

proc numFrames*(self: WaveRead): uint32 =
  ## Returns a count of sound frame.
  runnableExamples:
    var wav = openWaveReadFile("tests/testdata/sample1.wav")
    doAssert wav.numFrames == 80
    wav.close()

  self.dataSubChunk.size div self.blockAlign

proc readFrames*(self: WaveRead, n = 1): seq[byte] =
  ## Read sound frames from data of `DataSubChunk <#DataSubChunk>`_.
  ## A position of data moves when you use this proc.
  if n < 0: return
  for i in 0 ..< n * self.numFrames.int:
    result.add(self.dataSubChunk.data.readUint8)

proc pos*(self: WaveRead): int =
  ## Returns a position of data of `DataSubChunk <#DataSubChunk>`_.
  self.dataSubChunk.data.getPosition()

proc `pos=`*(self: WaveRead, n: int) =
  ## Set a position to data of `DataSubChunk <#DataSubChunk>`_.
  self.dataSubChunk.data.setPosition(n)

proc rewind*(self: WaveRead) =
  ## Set `audioStartPos` to `data.pos` of `DataSubChunk <#DataSubChunk>`_.
  self.pos = self.audioStartPos

proc openWaveReadFile*(file: string): WaveRead =
  ## Opens `file` and returns `WaveRead <#WaveRead>`_ object.
  ## Last, you must `close <#close,WaveRead>`_ `WaveRead <#WaveRead>`_ object.
  var strm = newFileStream(file, fmRead)
  result = WaveRead()
  result.riffChunkDescriptor = strm.parseRIFFChunkDescriptor()

  var
    formatSubChunkWasWritten: bool
    dataSubChunkWasWritten: bool
  # Note: dataサブチャンクより後にオプションのサブチャンクが配置されることはある
  # のか？
  while not strm.atEnd or (not formatSubChunkWasWritten and not dataSubChunkWasWritten):
    let id = strm.peekStr(4)
    case id
    of formatSubChunkId:
      result.formatSubChunk = strm.parseFormatSubChunk()
      formatSubChunkWasWritten = true
    of dataSubChunkId:
      result.audioStartPos = strm.getPosition() + 8
      result.dataSubChunk = strm.parseDataSubChunk()
      dataSubChunkWasWritten = true
    of factSubChunkId:
      result.factSubChunk = strm.parseFactSubChunk()
    else:
      strm.skipChunk()
  if not formatSubChunkWasWritten:
    raise newException(WaveFormatError, "format chunk is empty")
  if not dataSubChunkWasWritten:
    raise newException(WaveFormatError, "data chunk is empty")
  result.rewind()

proc close*(self: WaveRead) = self.dataSubChunk.data.close()

proc `$`*(self: WaveRead): string = $self[]
