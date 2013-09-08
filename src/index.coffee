"use strict"

fs          = require 'fs'
path        = require 'path'

_           = require 'lodash'
browserify  = require 'browserify'
logger      = require 'logmimosa'
shim        = require 'browserify-shim'
wrench      = require 'wrench'

config      = require './config'

registration = (mimosaConfig, register) ->
  e = mimosaConfig.extensions
  register ['postClean'], 'init', _clean
  register ['add','update','remove'], 'afterWrite', _browserify, [e.javascript..., e.template...]
  register ['postBuild'], 'optimize', _browserify

  for name, cfg of mimosaConfig.browserify.shims
    cfg.path = path.join mimosaConfig.watch.compiledDir, cfg.path

_clean = (mimosaConfig, options, next) ->
  for bundleConfig in mimosaConfig.browserify.bundles
    outputFile = bundleConfig.outputFile
    bundlePath = path.join mimosaConfig.watch.compiledJavascriptDir, outputFile
    if fs.existsSync bundlePath
      fs.unlinkSync bundlePath
      logger.success "Browserify - Removed bundle [[ #{outputFile} ]]"

  next()

_browserify = (mimosaConfig, options, next) ->
  root = mimosaConfig.watch.compiledDir
  browserifyConfig = mimosaConfig.browserify

  plural = browserifyConfig.bundles.length > 1
  logger.info "Browserify - Creating bundle#{if plural then 's' else ''}"

  bundledFiles = []
  whenDone = _whenDone mimosaConfig, bundledFiles, next
  for bundleConfig in browserifyConfig.bundles
    outputFile = bundleConfig.outputFile
    bundlePath = path.join mimosaConfig.watch.compiledJavascriptDir, outputFile

    browerifyOptions =
      debug: bundleConfig.debug ? browserifyConfig.debug ? true

    b = browserify()
    b.on 'file', (fileName) -> bundledFiles.push fileName

    _makeAliases b, mimosaConfig
    _makeShims b, mimosaConfig, browserifyConfig.bundles

    for entry in bundleConfig.entries
      b.add path.join root, entry

    bundleCallback = _bundleCallback bundleConfig, bundlePath, whenDone
    bundle         = b.bundle browerifyOptions, bundleCallback


_makeAliases = (browserifyInstance, mimosaConfig) ->
  b = browserifyInstance
  aliases = mimosaConfig.browserify.aliases
  root = mimosaConfig.watch.compiledDir
  if not aliases? then return

  for k,v of aliases
    b.require path.join(root, v), expose: k


_makeShims = (browserifyInstance, mimosaConfig, bundleConfig) ->
  b = browserifyInstance
  shims =
    if bundleConfig.shims?
      _.pick mimosaConfig.browserify.shims, bundleConfig.shims
    else
      mimosaConfig.browserify.shims

  shim b, shims


_whenDone = (mimosaConfig, bundledFiles, next) ->
  numBundles = mimosaConfig.browserify.bundles.length
  bundlesComplete = 0
  ->
    bundlesComplete += 1
    if bundlesComplete is numBundles
      if mimosaConfig.isBuild
        _cleanUpBuild mimosaConfig, bundledFiles
      next()


_cleanUpBuild = (mimosaConfig, bundledFiles) ->
  bundledFiles = _.uniq bundledFiles
  for f in bundledFiles
    if fs.existsSync f
      fs.unlinkSync f

  # now clean up empty directories
  compDir = mimosaConfig.watch.compiledDir
  directories = wrench.readdirSyncRecursive(compDir).filter (f) -> fs.statSync(path.join(compDir, f)).isDirectory()
  _.sortBy(directories, 'length').reverse().map (dir) ->
    path.join(compDir, dir)
  .forEach (dirPath) ->
    if fs.existsSync dirPath
      try
        fs.rmdirSync dirPath
        # logger.success "Deleted empty directory [[ #{dirPath} ]]"
      catch err
        if err.code is 'ENOTEMPTY'
          #logger.info "Unable to delete directory [[ #{dirPath} ]] because directory not empty"
        else
          #logger.error "Unable to delete directory, [[ #{dirPath} ]]"
          #logger.error err

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