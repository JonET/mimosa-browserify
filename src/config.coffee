"use strict"

exports.defaults = ->
  browserify:
    entries: ['public/javascripts/main.js']
    outputFile: 'bundle.js'
    debug: true

exports.placeholder = ->
  """
  \t

    #browserify:
      #entries: ['public/javascripts/main.js']  # application entry points
      #outputFile: 'bundle.js'                  # the bundled output file
      #debug: true                              # 'true' to generate source maps in the bundled output

  """

exports.validate = (config, validators) -> [] #tbd
