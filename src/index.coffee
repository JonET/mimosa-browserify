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
  register ['add','update','remove'], 'afterWrite', _browserify, [e.javascript..., e.template...]
  register ['postBuild'], 'optimize', _browserify

  for name, cfg of mimosaConfig.browserify.shims
    cfg.path = path.join mimosaConfig.watch.compiledDir, cfg.path

_browserify = (mimosaConfig, options, next) ->
  root = mimosaConfig.watch.compiledDir
  browserifyConfig = mimosaConfig.browserify

  plural = browserifyConfig.bundles.length > 1
  logger.info "Browserify - Creating bundle#{if plural then 's' else ''}"

  nextIfDone = _nextIfDone browserifyConfig.bundles.length, next
  for bundleConfig in browserifyConfig.bundles
    outputFile = bundleConfig.outputFile
    bundlePath = path.join mimosaConfig.watch.compiledJavascriptDir, outputFile

    browerifyOptions =
      debug: bundleConfig.debug ? browserifyConfig.debug ? true

    shimOptions =
      if bundleConfig.shims?
        _.pick browserifyConfig.shims, bundleConfig.shims
      else
        browserifyConfig.shims

    b = shim browserify(), shimOptions
    for entry in bundleConfig.entries
      b.add path.join root, entry

    bundleCallback = _bundleCallback bundleConfig, bundlePath, nextIfDone
    bundle         = b.bundle browerifyOptions, bundleCallback

_nextIfDone = (numBundles, next) ->
  bundlesComplete = 0
  ->
    bundlesComplete += 1
    next() if bundlesComplete is numBundles


_bundleCallback = (bundleConfig, bundlePath, complete) ->
  (err, src) ->
    if err?
      logger.error "Browserify [[ #{bundleConfig.outputFile} ]] - #{err}"
    else if src?
      fs.writeFileSync bundlePath, src
      logger.success "Browserify - Created bundle [[ #{bundleConfig.outputFile} ]]"
    complete()

module.exports =
  registration:    registration
  defaults:        config.defaults
  placeholder:     config.placeholder
  validate:        config.validate