"use strict"

logger = require 'logmimosa'
config = require './config'
browserify = require 'browserify'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

registration = (mimosaConfig, register) ->
  e = mimosaConfig.extensions
  register ['add','update','remove'], 'afterCompile', _browserify, e.javascript
  register ['postBuild'], 'optimize', _browserify

_browserify = (mimosaConfig, options, next) ->
  compiledJavascriptDir = mimosaConfig.watch.compiledJavascriptDir
  outputFile = mimosaConfig.browserify.outputFile
  bundlePath = path.join compiledJavascriptDir, outputFile

  browerifyOptions =
    debug: mimosaConfig.browserify.debug

  logger.info 'Creating Browserify Bundle'
  b = browserify()
  for entry in mimosaConfig.browserify.entries
    b.add path.join mimosaConfig.root, entry
  b.bundle(browerifyOptions).pipe(fs.createWriteStream(bundlePath))

  next()

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate