"use strict"

_           = require 'lodash'
browserify  = require 'browserify'
fs          = require 'fs'
path        = require 'path'
shim        = require 'browserify-shim'
through     = require 'through'
wrench      = require 'wrench'
config      = require './config'

logger      = null

registration = (mimosaConfig, register) ->
  logger = mimosaConfig.log

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

    browerifyOptions = {}

    unless mimosaConfig.isBuild
      browerifyOptions.debug = bundleConfig.debug ? browserifyConfig.debug ? true
    
    ctorOptions =
      noParse: _.map browserifyConfig.noParse, (f) -> path.join root, f

    b = browserify ctorOptions
    b.on 'file', (fileName) -> bundledFiles.push fileName

    _makeAliases b, mimosaConfig
    _makeShims b, mimosaConfig, browserifyConfig.bundles
    _fixShims b, mimosaConfig

    for entry in bundleConfig.entries
      b.add path.join root, entry      

    if bundleConfig.external?
      for external in bundleConfig.external
        entry = path.join root, external
        b.external entry

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

_fixShims = (browserifyInstance, mimosaConfig) ->
  # So it turns out that if you use a shim with the noParse option
  # things break as the shims require 'global' to be defined
  # and not parsing the file results in it being always undefined.
  # This just patches 'global' into the shim so that we don't
  # need to have browserify parse large dependencies.
  b = browserifyInstance
  b.transform (file) ->
    return through() unless _isShimmedAndNotParsed(file, mimosaConfig)
    data = 'var global=self;'
    write = (buffer) -> data += buffer
    end = ->
      @queue data
      @queue null
    through write, end

_isShimmedAndNotParsed = (file, mimosaConfig) ->
  file = _normalizePath file

  browserifyConfig = mimosaConfig.browserify
  shimmedPaths = []
  _.forIn browserifyConfig.shims, (v, k) ->
    shimmedPaths.push _normalizePath(v.path)

  noParsePaths = _.map browserifyConfig.noParse, (f) ->
    _normalizePath(path.join(mimosaConfig.watch.compiledDir, f))

  shimmedAndNotParsed = _.contains(shimmedPaths, file) and _.contains(noParsePaths, file)
  logger.debug "[[ #{file} ]] _isShimmedAndNotParsed :: #{shimmedAndNotParsed}"
  shimmedAndNotParsed

_normalizePath = (file) ->
  if path.extname(file) is '.js'
    file = file.slice 0, -3

  file

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
  filesToClean = bundledFiles.filter (f) -> !f.match /[\\\/]node_modules[\\\/]/
  filesToClean.forEach (f) ->
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
        logger.debug "Deleted empty directory [[ #{dirPath} ]]"
      catch err
        if err.code is 'ENOTEMPTY'
          logger.debug "Unable to delete directory [[ #{dirPath} ]] because directory not empty"
        else
          logger.error "Unable to delete directory, [[ #{dirPath} ]]"
          logger.error err

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
