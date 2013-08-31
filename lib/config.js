"use strict";
exports.defaults = function() {
  return {
    browserify: {
      entries: ['public/javascripts/main.js'],
      outputFile: 'bundle.js',
      debug: true
    }
  };
};

exports.placeholder = function() {
  return "\t\n\n  #browserify:\n    #entries: ['public/javascripts/main.js']  # application entry points\n    #outputFile: 'bundle.js'                  # the bundled output file\n    #debug: true                              # 'true' to generate source maps in the bundled output\n";
};

exports.validate = function(config, validators) {
  return [];
};
