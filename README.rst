====
wave
====

|nimble-version| |nimble-install| |nimble-docs| |gh-actions|

The wave is a tiny WAV sound module.
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

See `Usage section <https://jiro4989.github.io/wave/wave.html>`_.

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

* `WAVE PCM soundfile format <http://soundfile.sapp.org/doc/WaveFormat/>`_

.. include:: wave.nimble
   :literal:

.. |gh-actions| image:: https://github.com/jiro4989/wave/workflows/build/badge.svg
   :target: https://github.com/jiro4989/wave/actions
.. |nimble-version| image:: https://nimble.directory/ci/badges/wave/version.svg
   :target: https://nimble.directory/ci/badges/wave/nimdevel/output.html
.. |nimble-install| image:: https://nimble.directory/ci/badges/wave/nimdevel/status.svg
   :target: https://nimble.directory/ci/badges/wave/nimdevel/output.html
.. |nimble-docs| image:: https://nimble.directory/ci/badges/wave/nimdevel/docstatus.svg
   :target: https://nimble.directory/ci/badges/wave/nimdevel/doc_build_output.html
