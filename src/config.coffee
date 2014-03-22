"use strict"

exports.defaults = ->
  browserify:
    bundles: [
      entries: ['javascripts/main.js']
      outputFile: 'bundle.js' ]
    debug: true
    shims: {}
    aliases: {}
    noParse: []

exports.placeholder = ->
  """
    # browserify:
    #   bundles: [                          # add one or more bundles with one or more entry points
    #     entries: ['javascripts/main.js']
    #     outputFile: 'bundle.js' ]
    #   debug: true                         # true for sourcemaps. note: sourcemaps are always disabled for builds
    #   shims: {}                           # add any number of shims you neeed
    #                                       # see https://github.com/thlorenz/browserify-shim for config details
    #   aliases:
    #     dust: 'javascripts/vendor/dust'   # aliases allow you to require('alias') without having
    #                                       # to worry about relative paths. define as many as you need!
    #
    #   noParse:                            # an array of files you want browserify to skip parsing for.
    #     ['javascripts/vendor/jquery']     # useful for the big libs (jquery, ember, handlebars, dust, etc) that don't
    #                                       # need node environment vars (__process, global, etc). This can save
    #                                       # a significant amount of time when bundling.
  """

exports.validate = (config, validators) ->
  errors = []

  if validators.ifExistsIsObject(errors, "browserify config", config.browserify)
    validators.ifExistsIsBoolean(errors, "browserify.debug", config.browserify.debug)
    validators.ifExistsIsObject(errors, "browserify.shims", config.browserify.shims)
    validators.ifExistsIsObject(errors, "browserify.aliases", config.browserify.aliases)
    validators.ifExistsIsArray(errors, "browserify.noParse", config.browserify.noParse)

    if validators.isArray(errors, "browserify.bundles", config.browserify.bundles)
      for bund in config.browserify.bundles
        if validators.ifExistsIsObject(errors, "browserify.bundles entries", bund)
          if bund.entries and Array.isArray(bund.entries)
            if bund.entries.length is 0
              errors.push "browserify.bundles.entries array cannot be empty."
            else
              validators.isArrayOfStrings(errors, "browserify.bundles.entries", bund.entries)
          else
            errors.push "Each browserify.bundles entry must contain an entries array"

          if bund.outputFile
            validators.isString(errors, "browserify.bundles.outputFile", bund.outputFile)
          else
            errors.push "Each browserify.bundles entry must contain an outputFile string"

  errors
