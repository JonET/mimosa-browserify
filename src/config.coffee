"use strict"

exports.defaults = ->
  browserify:
    bundles: [
      entries: ['javascripts/main.js']
      outputFile: 'bundle.js' ]
    debug: true
    shims: []
    aliases: {}

exports.placeholder = ->
  """
    # browserify:
    #   bundles: [                          # add one or more bundles with one or more entry points
    #     entries: ['javascripts/main.js']
    #     outputFile: 'bundle.js' ]
    #   debug: true                         # true for sourcemaps
    #   shims: []                           # add any number of shims you neeed
    #                                       # see https://github.com/thlorenz/browserify-shim for config details
    #   aliases:
    #     dust: 'javascripts/vendor/dust'   # aliases allow you to require('alias') without having
    #                                       # to worry about relative paths. define as many as you need!
  """

exports.validate = (config, validators) -> [] #tbd
