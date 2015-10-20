gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
cssmin = require 'gulp-cssmin'
shell = require 'gulp-shell'
gutil = require 'gulp-util'
debug = require 'gulp-debug'
sourcemaps = require 'gulp-sourcemaps'
watch = require 'gulp-watch'
livereload = require 'gulp-livereload'

# CONFIGURATION #

js_library_file = "libs.min.js"
compiled_js_directory = "./_attachments/js/"
app_file = "app.min.js"
css_file = "style.min.css"
css_file_dir = "./_attachments/css/"

css_files = ("./_attachments/css/#{file}" for file in [
    "jquery.mobile-1.1.0.min.css"
    "jquery.mobile.datebox.min.css"
    "jquery.tagit.css"
    "tablesorter.css"
    "jquery.dataTables.css"
    "dataTables.tableTools.min.css"
    "designview.css"
    "galaxytab.css"
    "pivot.css"
])

js_library_files = ("./_attachments/js-libraries/#{file}" for file in [
    "d3.v3.min.js"
    "jquery-2.1.0.min.js"
    "jquery-migrate-1.2.1.min.js"
    "jquery-ui.js"
    "pivot.js"
    "d3_renderers.js"
    "underscore-min.js"
    "backbone-min.js"
    "jquery.couch.js"
    "backbone-couchdb.js"
    "jqm-config.js"
    "jquery.mobile-1.1.0.min.js"
    "jquery.mobile.datebox.min.js"
    "jqm.autoComplete.min-1.3.js"
    "handlebars.js"
    "form2js.js"
    "js2form.js"
    "jquery.toObject.js"
    "inflection.js"
    "jquery.dateFormat-1.0.js"
    "table2CSV.js"
    "jquery.tablesorter.min.js"
    "jquery.dataTables.min.js"
    "dataTables.tableTools.min.js"
    "picnet.table.filter.min.js"
    "jquery.table-filter.min.js"
    "tag-it.js"
    "moment.min.js"
    "jquery.cookie.js"
    "base64.js"
    "sha1.js"
    "coffee-script.js"
    "typeahead.min.js"
])


app_files = ("./_attachments/#{file}" for file in [
    "config.coffee"
    "models/User.coffee"
    "models/Config.coffee"
    "models/Question.coffee"
    "models/QuestionCollection.coffee"
    "models/Result.coffee"
    "models/ResultCollection.coffee"
    "models/Sync.coffee"
    "models/LocalConfig.coffee"
    "models/Message.coffee"
    "models/MessageCollection.coffee"
    "models/Help.coffee"
    "views/LoginView.coffee"
    "views/DesignView.coffee"
    "views/QuestionView.coffee"
    "views/MenuView.coffee"
    "views/ResultsView.coffee"
    "views/ResultSummaryEditorView.coffee"
    "views/SyncView.coffee"
    "views/ManageView.coffee"
    "views/LocalConfigView.coffee"
    "views/ReportView.coffee"
    "views/CaseView.coffee"
    "views/UsersView.coffee"
    "views/MessagingView.coffee"
    "views/HelpView.coffee"
    "app.coffee"
])

compile_and_concat = () ->
  gutil.log "Combining javascript libraries into #{js_library_file}"
  gulp.src js_library_files
    .pipe debug({title: "Adding library"})
    .pipe sourcemaps.init()
    .pipe concat js_library_file
    .pipe sourcemaps.write()
    .pipe gulp.dest compiled_js_directory

  gutil.log "Compiling coffeescript and combining into #{app_file}"
  gulp.src app_files
    .pipe debug({title: "Compiling coffeescript"})
    .pipe sourcemaps.init()
    .pipe coffee
      bare: true
    .on 'error', gutil.log
    .pipe concat app_file
    .pipe sourcemaps.write()
    .pipe gulp.dest compiled_js_directory

  gutil.log "Combining css into #{css_file}"
  gulp.src css_files
    .pipe concat css_file
    .pipe gulp.dest css_file_dir

couchapp_push = (destination = "default") ->
  gutil.log "Pushing to couchdb"
  gulp.src("").pipe shell(["couchapp push #{destination}"])

minify = () ->
  for file in [js_library_file, app_file]
    gutil.log "uglifying: #{file}"
    gulp.src "#{compiled_js_directory}#{file}"
      .pipe uglify()
      .pipe concat file
      .pipe gulp.dest compiled_js_directory

  # Note that cssmin doesn't reduce file size much
  gutil.log "cssmin'ing #{css_file_dir}#{css_file}"
  gulp.src "#{css_file_dir}#{css_file}"
    .pipe cssmin()
    .pipe concat css_file
    .pipe gulp.dest css_file_dir

develop = () ->
  compile_and_concat()
  couchapp_push()
  livereload.reload()

gulp.task 'minify', ->
  compile_and_concat()
  minify()

gulp.task 'deploy', ->
  compile_and_concat()
  minify()
  couchapp_push("cloud")

gulp.task 'develop', ->
  compile_and_concat()
  couchapp_push()
  livereload.listen
    start: true
  gulp.watch app_files.concat(js_library_files).concat(css_files), develop

gulp.task 'default', ->
  compile_and_concat()
  minify()
