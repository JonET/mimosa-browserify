"use strict"

browserify  = require 'browserify'
fs          = require 'fs'
logger      = require 'logmimosa'
path        = require 'path'
config      = require './config'

registration = (mimosaConfig, register) ->
  e = mimosaConfig.extensions
  register ['add','update','remove'], 'afterCompile', _browserify, e.javascript
  register ['postBuild'], 'optimize', _browserify

_browserify = (mimosaConfig, options, next) ->
  compiledJavascriptDir = mimosaConfig.watch.compiledJavascriptDir

  logger.info 'Creating Browserify Bundle(s)'

  for bundleConfig in mimosaConfig.browserify
    outputFile = bundleConfig.outputFile
    bundlePath = path.join compiledJavascriptDir, outputFile

    browerifyOptions =
      debug: bundleConfig.debug

    b = browserify()
    for entry in bundleConfig.entries
      b.add path.join mimosaConfig.root, entry

    bundle = b.bundle browerifyOptions, _bundleCallback(bundleConfig)
    bundle.pipe fs.createWriteStream bundlePath

  next()

_bundleCallback = (bundleConfig) ->
  (err, src) ->
    if err?
      logger.error("Browserify [[#{bundleConfig.outputFile}]] - #{err}")
    else if src?
      logger.success("Browserify - Created bundle [[ #{bundleConfig.outputFile} ]]")

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate