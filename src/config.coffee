"use strict"

exports.defaults = ->
  browserify:
    bundles: [
      entries: ['public/javascripts/main.js']
      outputFile: 'bundle.js' ]
    debug: true
    shims: []

exports.placeholder = ->
  """
  \t

    #browserify: [{                             # NOTE that browserify takes an array. You can configure multiple bundles if you wish.
      #entries: ['public/javascripts/main.js']  # application entry points
      #outputFile: 'bundle.js'                  # the bundled output file
      #debug: true }]                           # 'true' to generate source maps in the bundled output

  """

exports.validate = (config, validators) -> [] #tbd
