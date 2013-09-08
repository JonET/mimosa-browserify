# mimosa-browserify
[Mimosa](https://github.com/dbashford/mimosa) module to support CommonJS via [Browserify](https://github.com/substack/node-browserify). `require()` your web modules Node.js style!
## usage
Replace `require` with `browserify` in your `mimosa-config.coffee`. Mimosa will automatically install mimosa-browserify from NPM if you don't already have it.
####Updating/Switching Versions
Use the `mimosa` cli to manage versions. `mimosa mod:list` will show you what you have installed.

To update to the lastest version: `mimosa mod:install mimosa-browserify`

You can also change to a specific version: `mimosa mod:install mimosa-browserify@0.1.2`
####Example configuration:
```coffee
exports.config =
  modules: ["server","browserify","lint","live-reload","bower"]
  template:
    wrapType: 'common'
    commonLibPath: 'dust'
  browserify:
    bundles:
      [
        entries: ['javascripts/main.js']
        outputFile: 'bundle.js'
      ]
    shims:
      jquery:
        path: 'javascripts/vendor/jquery/jquery'
        exports: '$'
    aliases:
      dust: 'javascripts/vendor/dust'
      templates: 'javascripts/templates'
    noParse: ['javascripts/vendor/jquery/jquery']
```
####shims
Note the use of shims to wrap non-CommonJS code. The documentation for the shim configuration can be found at [browserify-shim](https://github.com/thlorenz/browserify-shim).
####aliases
Aliases allow you to name your modules. This frees you from having to use relative paths. So in this example you could `require('dust')` instead of `require('./vendor/dust')`.
####noParse
Use noParse to let browserify know not to parse large vendor libraries with no node.js dependencies.  This can help shave a few seconds off of your build time.
####templates
Mimosa as of v1.0.0-rc.4 can output CommonJS wrapped templates compatible with mimosa-browserify. Be sure to set `template.wrapType` to `common` and set your `commonLibPath` if you want to use compiled templates. (you probably do)
## quickstart
There is an example project available [here](https://github.com/JonET/mimosa-browserify-example) to help you get started.
