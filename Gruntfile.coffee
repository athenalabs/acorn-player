module.exports = (grunt) ->


  # paths setup - separate as some modules dont process templates correctly
  paths =

    # coffescript sources
    coffee_dir: 'coffee'
    coffee_src: 'coffee/**/*.coffee'

    # javascript sources
    js_dir: 'js'
    js_src: 'js/src/**/*.js'
    js_specs: 'js/test/**/*.spec.js'

    # less sources
    less_dir: 'static/less'
    less_src: 'static/less/**/*.less'

    # css sources
    css_dir: 'static/css'
    css_src: 'static/css/**/*.css'
    css_dest: 'static/css/acorn-player.css'

    # build directory
    build_dir: 'build'

    # minified target name
    minified: 'build/acorn.player.min.js'

    # jasmine test page to render
    test_page: 'static/tests.html'

    # libraries to load in the frontend
    frontend_libs: [
      'lib/closure/library/closure/goog/base.js'     # for dependencies
      'node_modules/jquery-browser/lib/jquery.js'    # for dom manipulation
      'node_modules/underscore/underscore.js'        # for utilities
      'node_modules/backbone/backbone.js'            # for mvc apps
      'node_modules/grunt-jasmine-spec-server/lib/bootstrap/js/bootstrap.min.js'
      'lib/athena.lib.min.js'                        # for athena utils
      'lib/jquery/jquery.object-fit.js'              # for object-fit
      'lib/jquery/jquery-ui.custom.min.js'           # for rangeslider widget
      'lib/range_slider.js'                          # jquery-ui widget
    ]


  # YOU SHOULD NOT NEED TO MODIFY BELOW THIS LINE.
  # you may have to... if things break...


  # google closure paths
  paths.closure =

    # dependencies file
    deps: "#{paths.js_dir}/deps.js"

    # main entry point
    main: "#{paths.js_dir}/src/main.js"

    # output file for the compiler
    compiled: paths.minified

    # root of the sources that closure should use
    # silliness. because depswriter.py uses paths relative to closure library
    root_with_prefix: "'#{paths.js_dir} ../../../../../#{paths.js_dir}'"

    # path to library. this should be a submodule.
    library: 'lib/closure/library'

    # path to compiler. this should be a symlink (or the actual jar).
    compiler: 'lib/closure/compiler.jar'


  # jasmine paths
  paths.jasmine =

    # lib to include before sources (e.g. jquery, underscore, etc).
    lib: paths.frontend_libs

    # src to include. use closure deps and main entry point
    src: [paths.closure.deps, paths.closure.main]

    # specs to include.
    specs: paths.js_specs

    # view to render
    view: paths.test_page


  # Project configuration.
  grunt.initConfig

    # load package information
    pkg: grunt.file.readJSON 'package.json'

    # task to compile coffeescript into javascript
    coffee:
      default:
        src: paths.coffee_src
        dest: paths.js_dir
        options:
          preserve_dirs: true
          base_path: paths.coffee_dir

    # task to compute file dependencies (closure)
    closureDepsWriter:
      default:
        closureLibraryPath: paths.closure.library
        options:
          output_file: paths.closure.deps
          root_with_prefix: paths.closure.root_with_prefix

    # task to compile code into a minified file (closure)
    closureCompiler:
      default:
        js: paths.js_src
        closureCompiler: paths.closure.compiler
        checkModified: true
        options:
           # compilation_level: 'ADVANCED_OPTIMIZATIONS',
           # externs: ['path/to/file.js', '/source/**/*.js'],
           # define: ["'goog.DEBUG=false'"],
           # warning_level: 'verbose',
           # jscomp_off: ['checkTypes', 'fileoverviewTags'],
           # summary_detail_level: 3,
           formatting: 'PRETTY_PRINT'
           js_output_file: paths.closure.compiled
           output_wrapper: '"\'use strict\';\n(function(){%output%}).call(this);"'

    # task to run jasmine tests through the commandline via phantomjs
    jasmine:
      # concat because jasmine-runner doesnt support libs (before srcs)
      src: [].concat(paths.jasmine.lib, paths.jasmine.src)
      specs: paths.jasmine.specs

    # task to run jasmine tests in a webserver
    jasmineSpecServer:
      lib: paths.jasmine.lib
      src: paths.jasmine.src
      specs: paths.jasmine.specs
      view: paths.jasmine.view

    # task to watch sources for changes and recompile during development
    watch:
      files: [paths.coffee_src, paths.less_src]
      tasks: 'deps' # or 'test', or 'testserver' :)

    # task to run shell commands
    exec:
      # create the build directory. closure errors out if it isn't there...
      mkbuild: command: "mkdir -p #{paths.build_dir}"


    # task to clean up directories
    clean:

      # the generated javascript sources
      js: paths.js_dir

      # the generated css
      css: paths.css_dir

      # the generated build dir
      build: paths.build_dir

      # the generated jasmine-runner tester file
      test: ['_SpecRunner.html']

    # task to compile .less stylesheets to .css
    less:
      # .less -> .css compilation and minification
      prod:
        src: paths.less_src
        dest: paths.css_dest
        options:
          yuicompress: true
      # .less -> .css compilation only
      dev:
        src: paths.less_src
        dest: paths.css_dest



  # Load tasks
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-coffee'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-closure-tools'
  grunt.loadNpmTasks 'grunt-jasmine-runner'
  grunt.loadNpmTasks 'grunt-jasmine-spec-server'

  # Register tasks
  grunt.registerTask 'compile', ['coffee', 'less:dev', 'exec:mkbuild',
      'closureCompiler']
  grunt.registerTask 'deps', ['coffee', 'less:dev', 'closureDepsWriter']
  grunt.registerTask 'test', ['clean', 'deps', 'jasmine', 'clean:test']
  grunt.registerTask 'server', ['deps', 'jasmineSpecServer', 'watch']
  grunt.registerTask 'default', ['compile']
