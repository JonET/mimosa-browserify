# mimosa-browserify
[Mimosa](https://github.com/dbashford/mimosa) module to support CommonJS via [Browserify](https://github.com/substack/node-browserify). `require()` your web modules Node.js style!

## usage
Replace `require` with `browserify` in your `mimosa-config.coffee`. For example:
```coffee
modules: ['lint', 'server', 'browserify', 'live-reload', 'bower']
```
Configure the module as follows:
```coffee
browserify: [{
  entries: ['public/javascripts/main.js']  # application entry points
  outputFile: 'bundle.js'                  # the bundled output file
  debug: true }]                           # 'true' to generate source maps in the bundled output
```
Multiple bundles can be configured by adding to the browserify array.  This can be useful if you've partitioned your web site into several 'applications'.

## known issues
Currently Mimosa only outputs bare or AMD wrapped templates. You will need to use bare templates until CommonJS templates are supported.