====
wave
====

|gh-actions|

The wave is a tiny `WAV <https://en.wikipedia.org/wiki/WAV>`_ sound module.
It does not support compression/decompression, but it does support mono/stereo.
The wave is inspired by `Python wave <https://docs.python.org/3/library/wave.html>`_.

**Note:**
The wave is not supported some sub-chunks yet.
I will support sub-chunks (`fact`, `cue`, `plst`, `list`, `labl`, `note`, `ltxt`, `smpl`, `inst`) in the future.

.. contents:: Table of contents
   :depth: 3

Installation
============

.. code-block:: Bash

   nimble install wave

Usage
=====

Reading example
---------------

.. code-block:: nim

   import wave

   var wav = openWaveReadFile("tests/testdata/sample1.wav")
   doAssert wav.riffChunkDescriptorSize == 116
   doAssert wav.numChannels == numChannelsMono
   doAssert wav.sampleRate == 8000'u32
   doAssert wav.byteRate == 8000'u32
   doAssert wav.blockAlign == 1'u16
   doAssert wav.bitsPerSample == 8'u16
   doAssert wav.numFrames == 80
   doAssert wav.dataSubChunkSize == 80'u16
   echo wav
   ## Output:
   ## (riffChunkDescriptor: (id: "RIFF", size: 116, format: "WAVE"), formatSubChunk: (id: "fmt ", size: 16, format: 1, numChannels: 1, sampleRate: 8000, byteRate: 8000, blockAlign: 1, bitsPerSample: 8, extendedSize: 0, extended: @[]), dataSubChunk: (id: "data", size: 80, data: ...), audioStartPos: 44)

   wav.close()

Writing example
---------------

Square wave
^^^^^^^^^^^

.. code-block:: nim

   import wave

   var wav = openWaveWriteFile("tests/testdata/example_square.wav")

   wav.numChannels = numChannelsMono
   wav.sampleRate = 8000'u16

   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])
   wav.writeFrames([0xFF'u8, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00])

   wav.close()

Sine wave
^^^^^^^^^

.. code-block:: nim

   import wave
   import math

   let
     width = 127'f
     sampleRate = 44100'f
     hz = 440'f
     seconds = 3

   var wav = openWaveWriteFile("tests/testdata/example_sine.wav")

   wav.numChannels = numChannelsMono
   wav.sampleRate = sampleRate.uint16

   for _ in 0 ..< seconds:
     var buf: seq[byte]
     for i in 0 ..< sampleRate.int:
       let f = float(i)
       let b = byte(width * sin(2*PI*hz*f/sampleRate) + width)
       buf.add(b)
     wav.writeFrames(buf)

   wav.close()


API document
============

* https://jiro4989.github.io/wave/wave.html

Pull request
============

Welcome :heart:

LICENSE
=======

MIT

See also
========

English
-------

* `WAVE PCM soundfile format <http://soundfile.sapp.org/doc/WaveFormat/>`_
* `Wav file format -musicg-api <https://sites.google.com/site/musicgapi/technical-documents/wav-file-format#fact>`_

Japanese
--------

* `WAVE ファイルフォーマット <http://www.web-sky.org/program/other/wave.php>`_
* `cpython/Lib/wave.py <https://github.com/python/cpython/blob/3.8/Lib/wave.py>`_
* `WAVEファイル読み・書き込み <https://qiita.com/syuhei1008/items/0dd07489f58158fb4f83>`_
* `WAV (Waveform Audio File Format) <https://so-zou.jp/software/tech/file/format/wav/>`_
* `WAVE(WAV)ファイルフォーマット <https://uppudding.hatenadiary.org/entry/20071223/1198420222>`_
* `その103「WAVの構造と現状」 <https://bb.watch.impress.co.jp/cda/bbword/16386.html>`_

.. |gh-actions| image:: https://github.com/jiro4989/wave/workflows/build/badge.svg
   :target: https://github.com/jiro4989/wave/actions
