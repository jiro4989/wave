## http://www.web-sky.org/program/other/wave.php
## https://github.com/python/cpython/blob/3.8/Lib/wave.py
## https://qiita.com/syuhei1008/items/0dd07489f58158fb4f83
## https://so-zou.jp/software/tech/file/format/wav/#data-chunk
## https://uppudding.hatenadiary.org/entry/20071223/1198420222

import streams

type
  WaveRead* = ref object
    riffHeader: RiffHeader
    formatChunk: FormatChunk
    dataChunk: DataChunk
  WaveWrite* = ref object
    fileName: string
    riffHeader: RiffHeader
    formatChunk: FormatChunk
    dataChunk: DataChunk
  RiffHeader* = ref object # 12 byte
    id: string # 4byte
    size: uint32 # 4byte
    typ: string # 4byte
  FormatChunk* = ref object # 24 byte
    id: string # 4byte
    size: uint32 # 4byte
    format: uint16 # 2byte
    nChannels: uint16 # 2byte
    sampleRate: uint32 # 4byte
      ## 44.1kHz -> 44100
    frameRate: uint32 # 4byte
      ## 16ビットステレオリニアPCM サンプリングレート44100 -> 44100 * 2 * 2
    blockAlign: uint16 # 2byte
    bitsWidth: uint16 # 2byte
      ## 16ビットリニアPCM -> 16
      ## MS-ADPCM -> 4
    extendedSize: uint16 # 2byte
    extended: seq[byte] # n byte
  DataChunk* = ref object
    id: string ## 4byte 'data'
    size: uint32 ## 4byte idとsizeを除くデータサイズ
    data: StringStream ## n byte
  WaveFormatError* = object of CatchableError
  WaveDataIsEmptyError* = object of CatchableError

const
  WAVE_FORMAT_UNKNOWN*                  =  0x0000'u16  ## Microsoft
  WAVE_FORMAT_PCM*                      =  0x0001'u16  ## Microsoft
  WAVE_FORMAT_MS_ADPCM*                 =  0x0002'u16  ## Microsoft
  WAVE_FORMAT_IEEE_FLOAT*               =  0x0003'u16  ## Microsoft
  WAVE_FORMAT_VSELP*                    =  0x0004'u16  ## Compaq
  WAVE_FORMAT_IBM_CVSD*                 =  0x0005'u16  ## IBM
  WAVE_FORMAT_ALAW*                     =  0x0006'u16  ## Microsoft
  WAVE_FORMAT_MULAW*                    =  0x0007'u16  ## Microsoft
  WAVE_FORMAT_OKI_ADPCM*                =  0x0010'u16  ## OKI
  WAVE_FORMAT_IMA_ADPCM*                =  0x0011'u16  ## Intel
  WAVE_FORMAT_MEDIASPACE_ADPCM*         =  0x0012'u16  ## Videologic
  WAVE_FORMAT_SIERRA_ADPCM*             =  0x0013'u16  ## Sierra
  WAVE_FORMAT_G723_ADPCM*               =  0x0014'u16  ## Antex
  WAVE_FORMAT_DIGISTD*                  =  0x0015'u16  ## DSP
  WAVE_FORMAT_DIGIFIX*                  =  0x0016'u16  ## DSP
  WAVE_FORMAT_DIALOGIC_OKI_ADPCM*       =  0x0017'u16  ## Dialogic
  WAVE_FORMAT_MEDIAVISION_ADPCM*        =  0x0018'u16  ## Media
  WAVE_FORMAT_CU_CODEC*                 =  0x0019'u16  ## Hewlett-Packard
  WAVE_FORMAT_YAMAHA_ADPCM*             =  0x0020'u16  ## Yamaha
  WAVE_FORMAT_SONARC*                   =  0x0021'u16  ## Speech
  WAVE_FORMAT_DSPGROUP_TRUESPEECH*      =  0x0022'u16  ## DSP
  WAVE_FORMAT_ECHOSC1*                  =  0x0023'u16  ## Echo
  WAVE_FORMAT_AUDIOFILE_AF36*           =  0x0024'u16  ## Audiofile,
  WAVE_FORMAT_APTX*                     =  0x0025'u16  ## Audio
  WAVE_FORMAT_AUDIOFILE_AF10*           =  0x0026'u16  ## Audiofile,
  WAVE_FORMAT_PROSODY_1612*             =  0x0027'u16  ## Aculab
  WAVE_FORMAT_LRC*                      =  0x0028'u16  ## Merging
  WAVE_FORMAT_DOLBY_AC2*                =  0x0030'u16  ## Dolby
  WAVE_FORMAT_GSM610*                   =  0x0031'u16  ## Microsoft
  WAVE_FORMAT_MSNAUDIO*                 =  0x0032'u16  ## Microsoft
  WAVE_FORMAT_ANTEX_ADPCME*             =  0x0033'u16  ## Antex
  WAVE_FORMAT_CONTROL_RES_VQLPC*        =  0x0034'u16  ## Control
  WAVE_FORMAT_DIGIREAL*                 =  0x0035'u16  ## DSP
  WAVE_FORMAT_DIGIADPCM*                =  0x0036'u16  ## DSP
  WAVE_FORMAT_CONTROL_RES_CR10*         =  0x0037'u16  ## Control
  WAVE_FORMAT_NMS_VBXADPCM*             =  0x0038'u16  ## Natural
  WAVE_FORMAT_ROLAND_RDAC*              =  0x0039'u16  ## Roland
  WAVE_FORMAT_ECHOSC3*                  =  0x003A'u16  ## Echo
  WAVE_FORMAT_ROCKWELL_ADPCM*           =  0x003B'u16  ## Rockwell
  WAVE_FORMAT_ROCKWELL_DIGITALK*        =  0x003C'u16  ## Rockwell
  WAVE_FORMAT_XEBEC*                    =  0x003D'u16  ## Xebec
  WAVE_FORMAT_G721_ADPCM*               =  0x0040'u16  ## Antex
  WAVE_FORMAT_G728_CELP*                =  0x0041'u16  ## Antex
  WAVE_FORMAT_MSG723*                   =  0x0042'u16  ## Microsoft
  WAVE_FORMAT_MPEG*                     =  0x0050'u16  ## Microsoft
  WAVE_FORMAT_RT24*                     =  0x0052'u16  ## InSoft
  WAVE_FORMAT_PAC*                      =  0x0053'u16  ## InSoft
  WAVE_FORMAT_MPEGLAYER3*               =  0x0055'u16  ## MPEG
  WAVE_FORMAT_LUCENT_G723*              =  0x0059'u16  ## Lucent
  WAVE_FORMAT_CIRRUS*                   =  0x0060'u16  ## Cirrus
  WAVE_FORMAT_ESPCM*                    =  0x0061'u16  ## ESS
  WAVE_FORMAT_VOXWARE*                  =  0x0062'u16  ## Voxware
  WAVE_FORMAT_CANOPUS_ATRAC*            =  0x0063'u16  ## Canopus,
  WAVE_FORMAT_G726_ADPCM*               =  0x0064'u16  ## APICOM
  WAVE_FORMAT_G722_ADPCM*               =  0x0065'u16  ## APICOM
  WAVE_FORMAT_DSAT*                     =  0x0066'u16  ## Microsoft
  WAVE_FORMAT_DSAT_DISPLAY*             =  0x0067'u16  ## Microsoft
  WAVE_FORMAT_VOXWARE_BYTE_ALIGNED*     =  0x0069'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_AC8*              =  0x0070'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_AC10*             =  0x0071'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_AC16*             =  0x0072'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_AC20*             =  0x0073'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_RT24*             =  0x0074'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_RT29*             =  0x0075'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_RT29HW*           =  0x0076'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_VR12*             =  0x0077'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_VR18*             =  0x0078'u16  ## Voxware
  WAVE_FORMAT_VOXWARE_TQ40*             =  0x0079'u16  ## Voxware
  WAVE_FORMAT_SOFTSOUND*                =  0x0080'u16  ## Softsound,
  WAVE_FORMAT_VOXARE_TQ60*              =  0x0081'u16  ## Voxware
  WAVE_FORMAT_MSRT24*                   =  0x0082'u16  ## Microsoft
  WAVE_FORMAT_G729A*                    =  0x0083'u16  ## AT&T
  WAVE_FORMAT_MVI_MV12*                 =  0x0084'u16  ## Motion
  WAVE_FORMAT_DF_G726*                  =  0x0085'u16  ## DataFusion
  WAVE_FORMAT_DF_GSM610*                =  0x0086'u16  ## DataFusion
  WAVE_FORMAT_ONLIVE*                   =  0x0089'u16  ## OnLive!
  WAVE_FORMAT_SBC24*                    =  0x0091'u16  ## Siemens
  WAVE_FORMAT_DOLBY_AC3_SPDIF*          =  0x0092'u16  ## Sonic
  WAVE_FORMAT_ZYXEL_ADPCM*              =  0x0097'u16  ## ZyXEL
  WAVE_FORMAT_PHILIPS_LPCBB*            =  0x0098'u16  ## Philips
  WAVE_FORMAT_PACKED*                   =  0x0099'u16  ## Studer
  WAVE_FORMAT_RHETOREX_ADPCM*           =  0x0100'u16  ## Rhetorex,
  IBM_FORMAT_MULAW*                     =  0x0101'u16  ## IBM
  IBM_FORMAT_ALAW*                      =  0x0102'u16  ## IBM
  IBM_FORMAT_ADPCM*                     =  0x0103'u16  ## IBM
  WAVE_FORMAT_VIVO_G723*                =  0x0111'u16  ## Vivo
  WAVE_FORMAT_VIVO_SIREN*               =  0x0112'u16  ## Vivo
  WAVE_FORMAT_DIGITAL_G723*             =  0x0123'u16  ## Digital
  WAVE_FORMAT_CREATIVE_ADPCM*           =  0x0200'u16  ## Creative
  WAVE_FORMAT_CREATIVE_FASTSPEECH8*     =  0x0202'u16  ## Creative
  WAVE_FORMAT_CREATIVE_FASTSPEECH10*    =  0x0203'u16  ## Creative
  WAVE_FORMAT_QUARTERDECK*              =  0x0220'u16  ## Quarterdeck
  WAVE_FORMAT_FM_TOWNS_SND*             =  0x0300'u16  ## Fujitsu
  WAVE_FORMAT_BZV_DIGITAL*              =  0x0400'u16  ## Brooktree
  WAVE_FORMAT_VME_VMPCM*                =  0x0680'u16  ## AT&T
  WAVE_FORMAT_OLIGSM*                   =  0x1000'u16  ## Ing
  WAVE_FORMAT_OLIADPCM*                 =  0x1001'u16  ## Ing
  WAVE_FORMAT_OLICELP*                  =  0x1002'u16  ## Ing
  WAVE_FORMAT_OLISBC*                   =  0x1003'u16  ## Ing
  WAVE_FORMAT_OLIOPR*                   =  0x1004'u16  ## Ing
  WAVE_FORMAT_LH_CODEC*                 =  0x1100'u16  ## Lernout
  WAVE_FORMAT_NORRIS*                   =  0x1400'u16  ## Norris
  WAVE_FORMAT_SOUNDSPACE_MUSICOMPRESS*  =  0x1500'u16  ## AT&T
  WAVE_FORMAT_DVM*                      =  0x2000'u16  ## FAST
  WAVE_FORMAT_INTERWAV_VSC112*          =  0x7150'u16  ## ？？？？？
  WAVE_FORMAT_EXTENSIBLE*               =  0xFFFE'u16  ## ？？？？？

proc newRiffHeader*(data: openArray[byte]): RiffHeader =
  result = RiffHeader(id: "RIFF", size: data.sizeof.uint32, typ: "WAVE")

proc newFormatChunk*(format, nChannels: uint16,
                     sampleRate, frameRate: uint32,
                     blockAlign, bitsWidth: uint16): FormatChunk =
  result = FormatChunk(
    id: "fmt ",
    size: 16'u32,
    format: format,
    nChannels: nChannels,
    sampleRate: sampleRate,
    frameRate: frameRate,
    blockAlign: blockAlign,
    bitsWidth: bitsWidth,
  )

proc newDataChunk*(): DataChunk =
  result = DataChunk(
    id: "data",
    size: 0'u32,
    data: newStringStream(),
  )

proc parseRiffHeader*(strm: Stream): RiffHeader =
  ## 12 byte
  result = RiffHeader()
  result.id = strm.readStr(4)
  result.size = strm.readUint32()
  result.typ = strm.readStr(4)

proc parseFormatChunk*(strm: Stream): FormatChunk =
  ## 24 byte
  result = FormatChunk()
  result.id = strm.readStr(4)
  result.size = strm.readUint32()
  result.format = strm.readUint16()
  result.nChannels = strm.readUint16()
  result.sampleRate = strm.readUint32()
  result.frameRate = strm.readUint32()
  result.blockAlign = strm.readUint16()
  result.bitsWidth = strm.readUint16()
  if 16'u32 < result.size:
    result.extendedSize = strm.readUint16()
    for i in 0'u16 ..< result.extendedSize:
      result.extended.add(strm.readUint8())

proc openWaveReadFile*(file: string): WaveRead =
  var strm = newFileStream(file, fmRead)
  defer: strm.close()
  result = WaveRead()
  result.riffHeader = strm.parseRiffHeader()
  result.formatChunk = strm.parseFormatChunk()
  # result.data = strm.parseDataChunk()

proc openWaveWriteFile*(fileName: string): WaveWrite =
  result = WaveWrite()
  result.fileName = fileName
  result.riffHeader = newRiffHeader([])
  result.formatChunk = newFormatChunk(
    format=WAVE_FORMAT_PCM,
    nChannels=0'u16,
    sampleRate=0'u32,
    frameRate=0'u32,
    blockAlign=0'u16,
    bitsWidth=8'u16,
  )
  result.dataChunk = newDataChunk()

proc close*(self: WaveWrite) =
  let head = self.riffHeader
  let fmt = self.formatChunk

  if fmt.nChannels == 0: raise newException(WaveFormatError, "'nChannels' is not set")
  if fmt.sampleRate == 0: raise newException(WaveFormatError, "'sampleRate' is not set")
  if fmt.frameRate == 0: raise newException(WaveFormatError, "'frameRate' is not set")
  if fmt.blockAlign == 0: raise newException(WaveFormatError, "'blockAlign' is not set")
  if self.dataChunk.size == 0: raise newException(WaveDataIsEmptyError, "frames are not set")

  var outFile = newFileStream(self.fileName, fmWrite)
  # RIFF header
  outFile.write(head.id)
  outFile.write(head.size)
  outFile.write(head.typ)

  # Format chunk
  outFile.write(fmt.id)
  outFile.write(fmt.size)
  outFile.write(fmt.format)
  outFile.write(fmt.nChannels)
  outFile.write(fmt.sampleRate)
  outFile.write(fmt.frameRate)
  outFile.write(fmt.blockAlign)
  outFile.write(fmt.bitsWidth)

  # Data chunk
  outFile.write(self.dataChunk.id)
  outFile.write(self.dataChunk.size)

  self.dataChunk.data.setPosition(0)
  const bufSize = 1024
  var buffer: array[bufSize, byte]
  while true:
    let writtenSize = self.dataChunk.data.readData(addr(buffer), bufSize)
    if writtenSize == bufSize:
      outFile.write(buffer)
    elif 0 < writtenSize:
      for i in 0..<writtenSize:
        outFile.write(buffer[i])
    else:
      if self.dataChunk.data.atEnd:
        break

  outFile.close()
  self.dataChunk.data.close()

proc `nChannels=`*(self: var WaveWrite, nChannels: uint16) =
  self.formatChunk.nChannels = nChannels

proc `sampleRate=`*(self: var WaveWrite, sampleRate: uint16) =
  self.formatChunk.sampleRate = sampleRate

proc `frameRate=`*(self: var WaveWrite, frameRate: uint32) =
  self.formatChunk.frameRate = frameRate

proc `blockAlign=`*(self: var WaveWrite, blockAlign: uint16) =
  self.formatChunk.blockAlign = blockAlign

proc writeFrames*(self: WaveWrite, data: openArray[byte]) =
  self.dataChunk.size += data.len.uint32
  # Riff header + formatchunk + datachunk
  self.riffHeader.size = 4'u32 + 24'u32 + 8'u32 + self.dataChunk.size
  for b in data:
    self.dataChunk.data.write(b)

proc `$`*(self: RiffHeader): string = $self[]
proc `$`*(self: FormatChunk): string = $self[]
proc `$`*(self: DataChunk): string = $self[]
proc `$`*(self: WaveRead): string = $self[]
proc `$`*(self: WaveWrite): string = $self[]
