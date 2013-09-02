# mimosa-browserify
[Mimosa](https://github.com/dbashford/mimosa) module to support CommonJS via [Browserify](https://github.com/substack/node-browserify). `require()` your web modules Node.js style!
## usage
Replace `require` with `browserify` in your `mimosa-config.coffee`. For example:
```coffee
modules: ['lint', 'server', 'browserify', 'live-reload', 'bower']
```
Example configuration:
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
        exports: null
      jquery:
        path: 'javascripts/vendor/jquery/jquery'
        exports: '$'
```
Note the use of shims to wrap non-CommonJS code. The documentation for the shim configuration can be found at [browserify-shim](https://github.com/thlorenz/browserify-shim).
## templates
Currently Mimosa only outputs bare or AMD wrapped templates. You will need to use bare templates and a shim until CommonJS templates are supported.
