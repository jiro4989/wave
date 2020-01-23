## http://www.web-sky.org/program/other/wave.php
## https://github.com/python/cpython/blob/3.8/Lib/wave.py
## https://qiita.com/syuhei1008/items/0dd07489f58158fb4f83
## https://so-zou.jp/software/tech/file/format/wav/#data-chunk
## https://uppudding.hatenadiary.org/entry/20071223/1198420222

import os, streams

type
  Wave = ref object
    file: File
    channelsNumber: int
    framesNumber: int
  RiffHeader = ref object # 12 byte
    id: string # 4byte
    size: uint32 # 4byte
    rType: string # 4byte
  FormatChunk = ref object # 24 byte
    id: string # 4byte
    size: uint32 # 4byte
    format: array[2, byte] # 2byte
    channels: array[2, byte] # 2byte
    samplerate: uint32 # 4byte
      ## 44.1kHz -> 44100
    bytepersec: uint32 # 4byte
      ## 16ビットステレオリニアPCM サンプリングレート44100 -> 44100 * 2 * 2
    blockalign: array[2, byte] # 2byte
    bitswidth: array[2, byte] # 2byte
      ## 16ビットリニアPCM -> 16
      ## MS-ADPCM -> 4
  FormatChunkEx = ref object
    formatChunk: FormatChunk
    extendedSize: array[2, byte] # 2byte
    extended: seq[byte] # n byte
  DataChunk = ref object
    id: string ## 4byte 'data'
    size: uint32 ## 4byte idとsizeを除くデータサイズ
    waveformData: seq[byte] ## n byte

const
  WAVE_FORMAT_UNKNOWN                  =  [0x00,  0x00]  #  Microsoft
  WAVE_FORMAT_PCM                      =  [0x00,  0x01]  #  Microsoft
  WAVE_FORMAT_MS_ADPCM                 =  [0x00,  0x02]  #  Microsoft
  WAVE_FORMAT_IEEE_FLOAT               =  [0x00,  0x03]  #  Micrososft
  WAVE_FORMAT_VSELP                    =  [0x00,  0x04]  #  Compaq
  WAVE_FORMAT_IBM_CVSD                 =  [0x00,  0x05]  #  IBM
  WAVE_FORMAT_ALAW                     =  [0x00,  0x06]  #  Microsoft
  WAVE_FORMAT_MULAW                    =  [0x00,  0x07]  #  Microsoft
  WAVE_FORMAT_OKI_ADPCM                =  [0x00,  0x10]  #  OKI
  WAVE_FORMAT_IMA_ADPCM                =  [0x00,  0x11]  #  Intel
  WAVE_FORMAT_MEDIASPACE_ADPCM         =  [0x00,  0x12]  #  Videologic
  WAVE_FORMAT_SIERRA_ADPCM             =  [0x00,  0x13]  #  Sierra
  WAVE_FORMAT_G723_ADPCM               =  [0x00,  0x14]  #  Antex
  WAVE_FORMAT_DIGISTD                  =  [0x00,  0x15]  #  DSP
  WAVE_FORMAT_DIGIFIX                  =  [0x00,  0x16]  #  DSP
  WAVE_FORMAT_DIALOGIC_OKI_ADPCM       =  [0x00,  0x17]  #  Dialogic
  WAVE_FORMAT_MEDIAVISION_ADPCM        =  [0x00,  0x18]  #  Media
  WAVE_FORMAT_CU_CODEC                 =  [0x00,  0x19]  #  Hewlett-Packard
  WAVE_FORMAT_YAMAHA_ADPCM             =  [0x00,  0x20]  #  Yamaha
  WAVE_FORMAT_SONARC                   =  [0x00,  0x21]  #  Speech
  WAVE_FORMAT_DSPGROUP_TRUESPEECH      =  [0x00,  0x22]  #  DSP
  WAVE_FORMAT_ECHOSC1                  =  [0x00,  0x23]  #  Echo
  WAVE_FORMAT_AUDIOFILE_AF36           =  [0x00,  0x24]  #  Audiofile,
  WAVE_FORMAT_APTX                     =  [0x00,  0x25]  #  Audio
  WAVE_FORMAT_AUDIOFILE_AF10           =  [0x00,  0x26]  #  Audiofile,
  WAVE_FORMAT_PROSODY_1612             =  [0x00,  0x27]  #  Aculab
  WAVE_FORMAT_LRC                      =  [0x00,  0x28]  #  Merging
  WAVE_FORMAT_DOLBY_AC2                =  [0x00,  0x30]  #  Dolby
  WAVE_FORMAT_GSM610                   =  [0x00,  0x31]  #  Microsoft
  WAVE_FORMAT_MSNAUDIO                 =  [0x00,  0x32]  #  Microsoft
  WAVE_FORMAT_ANTEX_ADPCME             =  [0x00,  0x33]  #  Antex
  WAVE_FORMAT_CONTROL_RES_VQLPC        =  [0x00,  0x34]  #  Control
  WAVE_FORMAT_DIGIREAL                 =  [0x00,  0x35]  #  DSP
  WAVE_FORMAT_DIGIADPCM                =  [0x00,  0x36]  #  DSP
  WAVE_FORMAT_CONTROL_RES_CR10         =  [0x00,  0x37]  #  Control
  WAVE_FORMAT_NMS_VBXADPCM             =  [0x00,  0x38]  #  Natural
  WAVE_FORMAT_ROLAND_RDAC              =  [0x00,  0x39]  #  Roland
  WAVE_FORMAT_ECHOSC3                  =  [0x00,  0x3A]  #  Echo
  WAVE_FORMAT_ROCKWELL_ADPCM           =  [0x00,  0x3B]  #  Rockwell
  WAVE_FORMAT_ROCKWELL_DIGITALK        =  [0x00,  0x3C]  #  Rockwell
  WAVE_FORMAT_XEBEC                    =  [0x00,  0x3D]  #  Xebec
  WAVE_FORMAT_G721_ADPCM               =  [0x00,  0x40]  #  Antex
  WAVE_FORMAT_G728_CELP                =  [0x00,  0x41]  #  Antex
  WAVE_FORMAT_MSG723                   =  [0x00,  0x42]  #  Microsoft
  WAVE_FORMAT_MPEG                     =  [0x00,  0x50]  #  Microsoft
  WAVE_FORMAT_RT24                     =  [0x00,  0x52]  #  InSoft
  WAVE_FORMAT_PAC                      =  [0x00,  0x53]  #  InSoft
  WAVE_FORMAT_MPEGLAYER3               =  [0x00,  0x55]  #  MPEG
  WAVE_FORMAT_LUCENT_G723              =  [0x00,  0x59]  #  Lucent
  WAVE_FORMAT_CIRRUS                   =  [0x00,  0x60]  #  Cirrus
  WAVE_FORMAT_ESPCM                    =  [0x00,  0x61]  #  ESS
  WAVE_FORMAT_VOXWARE                  =  [0x00,  0x62]  #  Voxware
  WAVE_FORMAT_CANOPUS_ATRAC            =  [0x00,  0x63]  #  Canopus,
  WAVE_FORMAT_G726_ADPCM               =  [0x00,  0x64]  #  APICOM
  WAVE_FORMAT_G722_ADPCM               =  [0x00,  0x65]  #  APICOM
  WAVE_FORMAT_DSAT                     =  [0x00,  0x66]  #  Microsoft
  WAVE_FORMAT_DSAT_DISPLAY             =  [0x00,  0x67]  #  Microsoft
  WAVE_FORMAT_VOXWARE_BYTE_ALIGNED     =  [0x00,  0x69]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC8              =  [0x00,  0x70]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC10             =  [0x00,  0x71]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC16             =  [0x00,  0x72]  #  Voxware
  WAVE_FORMAT_VOXWARE_AC20             =  [0x00,  0x73]  #  Voxware
  WAVE_FORMAT_VOXWARE_RT24             =  [0x00,  0x74]  #  Voxware
  WAVE_FORMAT_VOXWARE_RT29             =  [0x00,  0x75]  #  Voxware
  WAVE_FORMAT_VOXWARE_RT29HW           =  [0x00,  0x76]  #  Voxware
  WAVE_FORMAT_VOXWARE_VR12             =  [0x00,  0x77]  #  Voxware
  WAVE_FORMAT_VOXWARE_VR18             =  [0x00,  0x78]  #  Voxware
  WAVE_FORMAT_VOXWARE_TQ40             =  [0x00,  0x79]  #  Voxware
  WAVE_FORMAT_SOFTSOUND                =  [0x00,  0x80]  #  Softsound,
  WAVE_FORMAT_VOXARE_TQ60              =  [0x00,  0x81]  #  Voxware
  WAVE_FORMAT_MSRT24                   =  [0x00,  0x82]  #  Microsoft
  WAVE_FORMAT_G729A                    =  [0x00,  0x83]  #  AT&T
  WAVE_FORMAT_MVI_MV12                 =  [0x00,  0x84]  #  Motion
  WAVE_FORMAT_DF_G726                  =  [0x00,  0x85]  #  DataFusion
  WAVE_FORMAT_DF_GSM610                =  [0x00,  0x86]  #  DataFusion
  WAVE_FORMAT_ONLIVE                   =  [0x00,  0x89]  #  OnLive!
  WAVE_FORMAT_SBC24                    =  [0x00,  0x91]  #  Siemens
  WAVE_FORMAT_DOLBY_AC3_SPDIF          =  [0x00,  0x92]  #  Sonic
  WAVE_FORMAT_ZYXEL_ADPCM              =  [0x00,  0x97]  #  ZyXEL
  WAVE_FORMAT_PHILIPS_LPCBB            =  [0x00,  0x98]  #  Philips
  WAVE_FORMAT_PACKED                   =  [0x00,  0x99]  #  Studer
  WAVE_FORMAT_RHETOREX_ADPCM           =  [0x01,  0x00]  #  Rhetorex,
  IBM_FORMAT_MULAW                     =  [0x01,  0x01]  #  IBM
  IBM_FORMAT_ALAW                      =  [0x01,  0x02]  #  IBM
  IBM_FORMAT_ADPCM                     =  [0x01,  0x03]  #  IBM
  WAVE_FORMAT_VIVO_G723                =  [0x01,  0x11]  #  Vivo
  WAVE_FORMAT_VIVO_SIREN               =  [0x01,  0x12]  #  Vivo
  WAVE_FORMAT_DIGITAL_G723             =  [0x01,  0x23]  #  Digital
  WAVE_FORMAT_CREATIVE_ADPCM           =  [0x02,  0x00]  #  Creative
  WAVE_FORMAT_CREATIVE_FASTSPEECH8     =  [0x02,  0x02]  #  Creative
  WAVE_FORMAT_CREATIVE_FASTSPEECH10    =  [0x02,  0x03]  #  Creative
  WAVE_FORMAT_QUARTERDECK              =  [0x02,  0x20]  #  Quarterdeck
  WAVE_FORMAT_FM_TOWNS_SND             =  [0x03,  0x00]  #  Fujitsu
  WAVE_FORMAT_BZV_DIGITAL              =  [0x04,  0x00]  #  Brooktree
  WAVE_FORMAT_VME_VMPCM                =  [0x06,  0x80]  #  AT&T
  WAVE_FORMAT_OLIGSM                   =  [0x10,  0x00]  #  Ing
  WAVE_FORMAT_OLIADPCM                 =  [0x10,  0x01]  #  Ing
  WAVE_FORMAT_OLICELP                  =  [0x10,  0x02]  #  Ing
  WAVE_FORMAT_OLISBC                   =  [0x10,  0x03]  #  Ing
  WAVE_FORMAT_OLIOPR                   =  [0x10,  0x04]  #  Ing
  WAVE_FORMAT_LH_CODEC                 =  [0x11,  0x00]  #  Lernout
  WAVE_FORMAT_NORRIS                   =  [0x14,  0x00]  #  Norris
  WAVE_FORMAT_SOUNDSPACE_MUSICOMPRESS  =  [0x15,  0x00]  #  AT&T
  WAVE_FORMAT_DVM                      =  [0x20,  0x00]  #  FAST
  WAVE_FORMAT_INTERWAV_VSC112          =  [0x71,  0x50]  #  ?????
  WAVE_FORMAT_EXTENSIBLE               =  [0xFF,  0xFE]  #

proc newRiffHeader(data: seq[byte]): RiffHeader =
  result = RiffHeader(id: "RIFF", size: data.sizeof.uint32, rType: "WAVE")

proc newFormatChunk(format, channels: array[2, byte],
                    sampleRate, bytePerSec: uint32,
                    blockAlign, bitsWidth: array[2, byte]): FormatChunk =
  result = FormatChunk(
    id: "fmt ",
    size: 16'u32,
    format: format,
    channels: channels,
    samplerate: sampleRate,
    bytepersec: bytePerSec,
    blockalign: blockAlign,
    bitswidth: bitsWidth,
  )

proc newDataChunk(waveFormData: seq[byte]): DataChunk =
  result = DataChunk(
    id: "data",
    size: waveFormData.len.uint32,
    waveformData: waveFormData,
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
  strm.read(result.format)
  strm.read(result.channels)
  result.samplerate = strm.readUint32()
  result.bytepersec = strm.readUint32()
  strm.read(result.blockalign)
  strm.read(result.bitswidth)

proc parseWaveFile*(file: string) =
  var strm = newFileStream(file, fmRead)
  defer: strm.close()
  # RIFF Header - 12byte
  var riffHeader = strm.parseRiffHeader()
  echo riffHeader[]
  # Format chunk - 24byte
  var fmtChunk = strm.parseFormatChunk()
  echo fmtChunk[]
  # Data chunk - N byte
  discard

# def openfp(f, mode=None):
#     warnings.warn("wave.openfp is deprecated since Python 3.7. "
#                   "Use wave.open instead.", DeprecationWarning, stacklevel=2)
#     return open(f, mode=mode)
