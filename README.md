# Noise Eater

Webapp which implements various wind noise detection alrorithms developed by the University of Salford.

## Prerequisites

 * [Compiled windDet in project directory](https://github.com/kenders2000/WindNoiseDetection) to do the actual processing
 * [AudioWaveform](https://github.com/bbcrd/audiowaveform) for non-Web Audio API browsers
 * [ffmpeg](https://www.ffmpeg.org/) for audio file conversion and slicing

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

 * `ruby NoiseEater.rb` and uncommenting `run!` like loads a basic but persistent webserver: good for testing uploads, bad for testing changing views/templates.
 * `shotgun` and commenting out `run!` loads a more design-friendly environment but reloads the server on each file load

## Credits

Developed in the University of Salford Acoustics Research Centre.

 * Webapp by [Dr. Kim Foale](http://alliscalm.net)
 * windDet by [Dr. Paul Kendrick](http://www.kenders.net/)
 * Project Manager  [Prof. Trevor Cox](https://acousticengineering.wordpress.com/trevor-cox/)