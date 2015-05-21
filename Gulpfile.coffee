gulp = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
cssmin = require 'gulp-cssmin'
shell = require 'gulp-shell'
gutil = require 'gulp-util'
debug = require 'gulp-debug'

gulp.task 'coffee', ->
  gulp.src ["./_attachments/app/**/*.coffee","./_attachments/app/*.coffee"]
  .pipe coffee
    bare: true
  .pipe gulp.dest "./_attachments/app/"

gulp.task 'css', ->
  css = [
    "jquery.mobile-1.1.0.min.css"
    "jquery.mobile.datebox.min.css"
    "jquery.tagit.css"
    "tablesorter.css"
    "jquery.dataTables.css"
    "dataTables.tableTools.min.css"
    "designview.css"
    "galaxytab.css"
    "pivot.css"
  ]
  css = ("./_attachments/css/#{file}" for file in css)

  gulp.src css
    .pipe cssmin()
    .pipe concat "style.min.css"
    .pipe gulp.dest "./_attachments/css/"

gulp.task 'libs', ->
  libs = [
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
  ]

  libs = ("./_attachments/js-libraries/#{file}" for file in libs)

  gulp.src libs
#    .pipe uglify()
    .pipe concat "libs.min.js"
    .pipe gulp.dest "./_attachments/js/"

gulp.task 'app', ->
  app = [
    "config.js"
    "models/User.js"
    "models/Config.js"
    "models/Question.js"
    "models/QuestionCollection.js"
    "models/Result.js"
    "models/ResultCollection.js"
    "models/Sync.js"
    "models/LocalConfig.js"
    "models/Message.js"
    "models/MessageCollection.js"
    "models/Help.js"
    "views/LoginView.js"
    "views/DesignView.js"
    "views/QuestionView.js"
    "views/MenuView.js"
    "views/ResultsView.js"
    "views/ResultSummaryEditorView.js"
    "views/SyncView.js"
    "views/ManageView.js"
    "views/LocalConfigView.js"
    "views/ReportView.js"
    "views/CaseView.js"
    "views/UsersView.js"
    "views/MessagingView.js"
    "views/HelpView.js"
    "app.js"
  ]

  app = ("./_attachments/#{file}" for file in app)
    
  gulp.src app
#  .pipe debug()
  .pipe uglify()
  .pipe concat "app.min.js"
  .pipe gulp.dest "./_attachments/js/"

gulp.task 'default', [
  'coffee'
  'libs'
  'css'
  'app'
]

#gulp.watch "./_attachments/*.html", ['app']
#gulp.watch ["./_attachments/app/**/*.coffee","./_attachments/app/*.coffee"], ['coffee','app']

