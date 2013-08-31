"use strict";
var browserify, config, fs, logger, path, registration, _, _browserify;

logger = require('logmimosa');

config = require('./config');

browserify = require('browserify');

fs = require('fs');

path = require('path');

_ = require('lodash');

registration = function(mimosaConfig, register) {
  var e;
  e = mimosaConfig.extensions;
  register(['add', 'update', 'remove'], 'afterCompile', _browserify, e.javascript);
  return register(['postBuild'], 'optimize', _browserify);
};

_browserify = function(mimosaConfig, options, next) {
  var b, browerifyOptions, bundle, bundlePath, compiledJavascriptDir, entry, outputFile, _i, _len, _ref;
  compiledJavascriptDir = mimosaConfig.watch.compiledJavascriptDir;
  outputFile = mimosaConfig.browserify.outputFile;
  bundlePath = path.join(compiledJavascriptDir, outputFile);
  browerifyOptions = {
    debug: mimosaConfig.browserify.debug
  };
  logger.info('Creating Browserify Bundle');
  b = browserify();
  _ref = mimosaConfig.browserify.entries;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    entry = _ref[_i];
    b.add(path.join(mimosaConfig.root, entry));
  }
  bundle = b.bundle(browerifyOptions, function(err, src) {
    if (err) {
      return logger.error("Browserify - " + err);
    }
  });
  bundle.pipe(fs.createWriteStream(bundlePath));
  return next();
};

module.exports = {
  registration: registration,
  defaults: config.defaults,
  placeholder: config.placeholder,
  validate: config.validate
};
