## http://www.web-sky.org/program/other/wave.php
## https://github.com/python/cpython/blob/3.8/Lib/wave.py
## https://qiita.com/syuhei1008/items/0dd07489f58158fb4f83
## https://so-zou.jp/software/tech/file/format/wav/#data-chunk
## https://uppudding.hatenadiary.org/entry/20071223/1198420222

import os, streams

type
  Wave* = ref object
    riffHeader*: RiffHeader
    formatChunk*: FormatChunk
    dataChunk*: DataChunk
  RiffHeader* = ref object # 12 byte
    id*: string # 4byte
    size*: uint32 # 4byte
    rType*: string # 4byte
  FormatChunk* = ref object # 24 byte
    id*: string # 4byte
    size*: uint32 # 4byte
    format*: uint16 # 2byte
    channels*: uint16 # 2byte
    sampleRate*: uint32 # 4byte
      ## 44.1kHz -> 44100
    bytePerSec*: uint32 # 4byte
      ## 16ビットステレオリニアPCM サンプリングレート44100 -> 44100 * 2 * 2
    blockAlign*: uint16 # 2byte
    bitsWidth*: uint16 # 2byte
      ## 16ビットリニアPCM -> 16
      ## MS-ADPCM -> 4
  FormatChunkEx* = ref object
    formatChunk*: FormatChunk
    extendedSize*: uint16 # 2byte
    extended*: seq[byte] # n byte
  DataChunk* = ref object
    id*: string ## 4byte 'data'
    size*: uint32 ## 4byte idとsizeを除くデータサイズ
    data*: seq[byte] ## n byte

const
  WAVE_FORMAT_UNKNOWN                  =  [0x00, 0x00]  #  Microsoft
  WAVE_FORMAT_PCM                      =  [0x01, 0x00]  #  Microsoft
  WAVE_FORMAT_MS_ADPCM                 =  [0x02, 0x00]  #  Microsoft
  WAVE_FORMAT_IEEE_FLOAT               =  [0x03, 0x00]  #  Micrososft
  WAVE_FORMAT_VSELP                    =  [0x04, 0x00]  #  Compaq
  WAVE_FORMAT_IBM_CVSD                 =  [0x05, 0x00]  #  IBM
  WAVE_FORMAT_ALAW                     =  [0x06, 0x00]  #  Microsoft
  WAVE_FORMAT_MULAW                    =  [0x07, 0x00]  #  Microsoft
  WAVE_FORMAT_OKI_ADPCM                =  [0x10, 0x00]  #  OKI
  WAVE_FORMAT_IMA_ADPCM                =  [0x11, 0x00]  #  Intel
  WAVE_FORMAT_MEDIASPACE_ADPCM         =  [0x12, 0x00]  #  Videologic
  WAVE_FORMAT_SIERRA_ADPCM             =  [0x13, 0x00]  #  Sierra
  WAVE_FORMAT_G723_ADPCM               =  [0x14, 0x00]  #  Antex
  WAVE_FORMAT_DIGISTD                  =  [0x15, 0x00]  #  DSP
  WAVE_FORMAT_DIGIFIX                  =  [0x16, 0x00]  #  DSP
  WAVE_FORMAT_DIALOGIC_OKI_ADPCM       =  [0x17, 0x00]  #  Dialogic
  WAVE_FORMAT_MEDIAVISION_ADPCM        =  [0x18, 0x00]  #  Media
  WAVE_FORMAT_CU_CODEC                 =  [0x19, 0x00]  #  Hewlett-Packard
  WAVE_FORMAT_YAMAHA_ADPCM             =  [0x20, 0x00]  #  Yamaha
  WAVE_FORMAT_SONARC                   =  [0x21, 0x00]  #  Speech
  WAVE_FORMAT_DSPGROUP_TRUESPEECH      =  [0x22, 0x00]  #  DSP
  WAVE_FORMAT_ECHOSC1                  =  [0x23, 0x00]  #  Echo
  WAVE_FORMAT_AUDIOFILE_AF36           =  [0x24, 0x00]  #  Audiofile,
  WAVE_FORMAT_APTX                     =  [0x25, 0x00]  #  Audio
  WAVE_FORMAT_AUDIOFILE_AF10           =  [0x26, 0x00]  #  Audiofile,
  WAVE_FORMAT_PROSODY_1612             =  [0x27, 0x00]  #  Aculab
  WAVE_FORMAT_LRC                      =  [0x28, 0x00]  #  Merging
  WAVE_FORMAT_DOLBY_AC2                =  [0x30, 0x00]  #  Dolby
  WAVE_FORMAT_GSM610                   =  [0x31, 0x00]  #  Microsoft
  WAVE_FORMAT_MSNAUDIO                 =  [0x32, 0x00]  #  Microsoft
  WAVE_FORMAT_ANTEX_ADPCME             =  [0x33, 0x00]  #  Antex
  WAVE_FORMAT_CONTROL_RES_VQLPC        =  [0x34, 0x00]  #  Control
  WAVE_FORMAT_DIGIREAL                 =  [0x35, 0x00]  #  DSP
  WAVE_FORMAT_DIGIADPCM                =  [0x36, 0x00]  #  DSP
  WAVE_FORMAT_CONTROL_RES_CR10         =  [0x37, 0x00]  #  Control
  WAVE_FORMAT_NMS_VBXADPCM             =  [0x38, 0x00]  #  Natural
  WAVE_FORMAT_ROLAND_RDAC              =  [0x39, 0x00]  #  Roland
  WAVE_FORMAT_ECHOSC3                  =  [0x3A, 0x00]  #  Echo
  WAVE_FORMAT_ROCKWELL_ADPCM           =  [0x3B, 0x00]  #  Rockwell
  WAVE_FORMAT_ROCKWELL_DIGITALK        =  [0x3C, 0x00]  #  Rockwell
  WAVE_FORMAT_XEBEC                    =  [0x3D, 0x00]  #  Xebec
  WAVE_FORMAT_G721_ADPCM               =  [0x40, 0x00]  #  Antex
  WAVE_FORMAT_G728_CELP                =  [0x41, 0x00]  #  Antex
  WAVE_FORMAT_MSG723                   =  [0x42, 0x00]  #  Microsoft
  WAVE_FORMAT_MPEG                     =  [0x50, 0x00]  #  Microsoft
  WAVE_FORMAT_RT24                     =  [0x52, 0x00]  #  InSoft
  WAVE_FORMAT_PAC                      =  [0x53, 0x00]  #  InSoft
  WAVE_FORMAT_MPEGLAYER3               =  [0x55, 0x00]  #  MPEG
  WAVE_FORMAT_LUCENT_G723              =  [0x59, 0x00]  #  Lucent
  WAVE_FORMAT_CIRRUS                   =  [0x60, 0x00]  #  Cirrus
  WAVE_FORMAT_ESPCM                    =  [0x61, 0x00]  #  ESS
  WAVE_FORMAT_VOXWARE                  =  [0x62, 0x00]  #  Voxware
  WAVE_FORMAT_CANOPUS_ATRAC            =  [0x63, 0x00]  #  Canopus,
  WAVE_FORMAT_G726_ADPCM               =  [0x64, 0x00]  #  APICOM
  WAVE_FORMAT_G722_ADPCM               =  [0x65, 0x00]  #  APICOM
  WAVE_FORMAT_DSAT                     =  [0x66, 0x00]  #  Microsoft
  WAVE_FORMAT_DSAT_DISPLAY             =  [0x67, 0x00]  #  Microsoft
  WAVE_FORMAT_VOXWARE_BYTE_ALIGNED     =  [0x69, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC8              =  [0x70, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC10             =  [0x71, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC16             =  [0x72, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC20             =  [0x73, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_RT24             =  [0x74, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_RT29             =  [0x75, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_RT29HW           =  [0x76, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_VR12             =  [0x77, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_VR18             =  [0x78, 0x00]  #  Voxware
  WAVE_FORMAT_VOXWARE_TQ40             =  [0x79, 0x00]  #  Voxware
  WAVE_FORMAT_SOFTSOUND                =  [0x80, 0x00]  #  Softsound,
  WAVE_FORMAT_VOXARE_TQ60              =  [0x81, 0x00]  #  Voxware
  WAVE_FORMAT_MSRT24                   =  [0x82, 0x00]  #  Microsoft
  WAVE_FORMAT_G729A                    =  [0x83, 0x00]  #  AT&T
  WAVE_FORMAT_MVI_MV12                 =  [0x84, 0x00]  #  Motion
  WAVE_FORMAT_DF_G726                  =  [0x85, 0x00]  #  DataFusion
  WAVE_FORMAT_DF_GSM610                =  [0x86, 0x00]  #  DataFusion
  WAVE_FORMAT_ONLIVE                   =  [0x89, 0x00]  #  OnLive!
  WAVE_FORMAT_SBC24                    =  [0x91, 0x00]  #  Siemens
  WAVE_FORMAT_DOLBY_AC3_SPDIF          =  [0x92, 0x00]  #  Sonic
  WAVE_FORMAT_ZYXEL_ADPCM              =  [0x97, 0x00]  #  ZyXEL
  WAVE_FORMAT_PHILIPS_LPCBB            =  [0x98, 0x00]  #  Philips
  WAVE_FORMAT_PACKED                   =  [0x99, 0x00]  #  Studer
  WAVE_FORMAT_RHETOREX_ADPCM           =  [0x00, 0x01]  #  Rhetorex,
  IBM_FORMAT_MULAW                     =  [0x01, 0x01]  #  IBM
  IBM_FORMAT_ALAW                      =  [0x02, 0x01]  #  IBM
  IBM_FORMAT_ADPCM                     =  [0x03, 0x01]  #  IBM
  WAVE_FORMAT_VIVO_G723                =  [0x11, 0x01]  #  Vivo
  WAVE_FORMAT_VIVO_SIREN               =  [0x12, 0x01]  #  Vivo
  WAVE_FORMAT_DIGITAL_G723             =  [0x23, 0x01]  #  Digital
  WAVE_FORMAT_CREATIVE_ADPCM           =  [0x00, 0x02]  #  Creative
  WAVE_FORMAT_CREATIVE_FASTSPEECH8     =  [0x02, 0x02]  #  Creative
  WAVE_FORMAT_CREATIVE_FASTSPEECH10    =  [0x03, 0x02]  #  Creative
  WAVE_FORMAT_QUARTERDECK              =  [0x20, 0x02]  #  Quarterdeck
  WAVE_FORMAT_FM_TOWNS_SND             =  [0x00, 0x03]  #  Fujitsu
  WAVE_FORMAT_BZV_DIGITAL              =  [0x00, 0x04]  #  Brooktree
  WAVE_FORMAT_VME_VMPCM                =  [0x80, 0x06]  #  AT&T
  WAVE_FORMAT_OLIGSM                   =  [0x00, 0x10]  #  Ing
  WAVE_FORMAT_OLIADPCM                 =  [0x01, 0x10]  #  Ing
  WAVE_FORMAT_OLICELP                  =  [0x02, 0x10]  #  Ing
  WAVE_FORMAT_OLISBC                   =  [0x03, 0x10]  #  Ing
  WAVE_FORMAT_OLIOPR                   =  [0x04, 0x10]  #  Ing
  WAVE_FORMAT_LH_CODEC                 =  [0x00, 0x11]  #  Lernout
  WAVE_FORMAT_NORRIS                   =  [0x00, 0x14]  #  Norris
  WAVE_FORMAT_SOUNDSPACE_MUSICOMPRESS  =  [0x00, 0x15]  #  AT&T
  WAVE_FORMAT_DVM                      =  [0x00, 0x20]  #  FAST
  WAVE_FORMAT_INTERWAV_VSC112          =  [0x50, 0x71]  #  ?????
  WAVE_FORMAT_EXTENSIBLE               =  [0xFE, 0xFF]  #

proc newRiffHeader*(data: seq[byte]): RiffHeader =
  result = RiffHeader(id: "RIFF", size: data.sizeof.uint32, rType: "WAVE")

proc newFormatChunk*(format, channels: uint16,
                    sampleRate, bytePerSec: uint32,
                    blockAlign, bitsWidth: uint16): FormatChunk =
  result = FormatChunk(
    id: "fmt ",
    size: 16'u32,
    format: format,
    channels: channels,
    sampleRate: sampleRate,
    bytePerSec: bytePerSec,
    blockAlign: blockAlign,
    bitsWidth: bitsWidth,
  )

proc newDataChunk*(data: seq[byte]): DataChunk =
  result = DataChunk(
    id: "data",
    size: data.len.uint32,
    data: data,
  )

proc openWaveFile*(f: string) =
  discard
    # if mode is None:
    #     if hasattr(f, 'mode'):
    #         mode = f.mode
    #     else:
    #         mode = 'rb'
    # if mode in ('r', 'rb'):
    #     return Wave_read(f)
    # elif mode in ('w', 'wb'):
    #     return Wave_write(f)
    # else:
    #     raise Error("mode must be 'r', 'rb', 'w', or 'wb'")

proc parseRiffHeader*(strm: Stream): RiffHeader =
  ## 12 byte
  result = RiffHeader()
  for i in 1..4:
    result.id.add(strm.readChar())
  result.size = strm.readUint32()
  for i in 1..4:
    result.rType.add(strm.readChar())

proc parseFormatChunk*(strm: Stream): FormatChunk =
  ## 24 byte
  result = FormatChunk()
  for i in 1..4:
    result.id.add(strm.readChar())
  result.size = strm.readUint32()
  result.format = strm.readUint16()
  result.channels = strm.readUint16()
  result.sampleRate = strm.readUint32()
  result.bytePerSec = strm.readUint32()
  result.blockAlign = strm.readUint16()
  result.bitsWidth = strm.readUint16()

proc parseWaveFile*(file: string): Wave =
  var strm = newFileStream(file, fmRead)
  defer: strm.close()
  result.riffHeader = strm.parseRiffHeader()
  result.fmtChunk = strm.parseFormatChunk()
  result.data = strm.parseDataChunk()
