# mimosa-browserify
[Mimosa](https://github.com/dbashford/mimosa) module to support CommonJS via [Browserify](https://github.com/substack/node-browserify). `require()` your web modules Node.js style!
## usage
Replace `require` with `browserify` in your `mimosa-config.coffee`. Mimosa will automatically install mimosa-browserify from NPM if you don't already have it.

####Example configuration:
```coffee
exports.config =
  modules: ["server","browserify","lint","live-reload","bower"]
  template: amdWrap: false
  browserify:
    bundles:
      [
        entries: ['javascripts/main.js']
        outputFile: 'bundle.js'
      ]
    shims:
      templates:
        path: 'javascripts/templates'
        exports: 'dust'
        depends:
          dust: 'dust'
      jquery:
        path: 'javascripts/vendor/jquery/jquery'
        exports: '$'
    aliases:
      dust: 'javascripts/vendor/dust'
      templates: 'javascripts/templates'
```
Note the use of shims to wrap non-CommonJS code. The documentation for the shim configuration can be found at [browserify-shim](https://github.com/thlorenz/browserify-shim).

Aliases allow you to name your modules. This frees you from having to use relative paths. So in this example you could `require('dust')` instead of `require('./vendor/dust')`. Aliases also make it nice when defining dependencies in your shims.  Here we alias `dust` and then declare that templates has a dependency on it. We also re-export the `dust` object to emulate the behavior of mimosa's AMD wrapped template. 
## quickstart
There is an example project available [here](https://github.com/JonET/mimosa-browserify-example) to help you get started.
## templates
Currently Mimosa only outputs bare or AMD wrapped templates. You will need to use bare templates and a shim until CommonJS templates are supported.
