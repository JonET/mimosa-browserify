"use strict"

_           = require 'lodash'
browserify  = require 'browserify'
fs          = require 'fs'
logger      = require 'logmimosa'
path        = require 'path'
shim        = require 'browserify-shim'
config      = require './config'

registration = (mimosaConfig, register) ->
  e = mimosaConfig.extensions
  register ['add','update','remove'], 'afterCompile', _browserify, e.javascript
  register ['postBuild'], 'optimize', _browserify

  for name, cfg of mimosaConfig.browserify.shims
    cfg.path = path.join mimosaConfig.root, cfg.path

_browserify = (mimosaConfig, options, next) ->
  compiledJavascriptDir = mimosaConfig.watch.compiledJavascriptDir
  browserifyConfig = mimosaConfig.browserify

  plural = browserifyConfig.bundles.length > 1
  logger.info "Browserify - Creating bundle#{if plural then 's' else ''} #{process.cwd()}"

  for bundleConfig in browserifyConfig.bundles
    outputFile = bundleConfig.outputFile
    bundlePath = path.join compiledJavascriptDir, outputFile

    browerifyOptions =
      debug: bundleConfig.debug ? browserifyConfig.debug ? true
      detectGlobals: false

    shimOptions =
      if bundleConfig.shims?
        _.pick browserifyConfig.shims, bundleConfig.shims
      else
        browserifyConfig.shims

    b = shim browserify(), shimOptions
    for entry in bundleConfig.entries
      b.add path.join mimosaConfig.root, entry

    bundle = b.bundle browerifyOptions, _bundleCallback(bundleConfig)
    bundle.pipe fs.createWriteStream bundlePath

  next()

_bundleCallback = (bundleConfig) ->
  (err, src) ->
    if err?
      logger.error "Browserify [[ #{bundleConfig.outputFile} ]] - #{err}"
    else if src?
      logger.success "Browserify - Created bundle [[ #{bundleConfig.outputFile} ]]"

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate