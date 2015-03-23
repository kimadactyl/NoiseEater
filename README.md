# Noise Eater

Webapp which implements various wind noise detection alrorithms developed by the University of Salford.

## Prerequisites

 * [`windDet`](https://github.com/kenders2000/WindNoiseDetection) to do the actual processing
 * [`audiowaveform`](https://github.com/bbcrd/audiowaveform)
 * [`ffmpeg`](https://www.ffmpeg.org/) for audio file conversion and slicing
 * `sendmail` or other mailserver to send validation emails

## Install & Configure

 * Copy `configuration/settings.rb.example` to `configuration/settings.rb` and set as appropriate.
 * `bundle --without production`
 * `rackup`

## What's what?

 * /features/: cucumber specs
 * /public/audio: upload location for audio files
 * /testdata/: files to test with
 * /trees/: descision trees for windDet
 * config.rb: website config
 * config.ru: rackup config
 * NoiseEater.rb: website app
 * fileprocessor.rb: audio file processing server
 * windDet: audio processing binary

## Loading

 * `rackup`

In the console output, server messages are in green, command line tools in yellow, user interaction in blue and errors in red.

## Credits

Developed in the University of Salford Acoustics Research Centre.

 * Webapp by [Dr. Kim Foale](http://alliscalm.net)
 * windDet by [Dr. Paul Kendrick](http://www.kenders.net/)
 * Project Manager  [Prof. Trevor Cox](https://acousticengineering.wordpress.com/trevor-cox/)