// Generated by CoffeeScript 1.9.0
var base_dir, coffee, concat, cssmin, debug, gulp, gutil, shell, uglify;

gulp = require('gulp');

coffee = require('gulp-coffee');

concat = require('gulp-concat');

uglify = require('gulp-uglify');

cssmin = require('gulp-cssmin');

shell = require('gulp-shell');

gutil = require('gulp-util');

debug = require('gulp-debug');

base_dir = "/var/www/coconut-core/_attachments";

gulp.task('coffee', function() {
  return gulp.src([base_dir + "/app/**/*.coffee", base_dir + "/app/*.coffee"]).pipe(coffee({
    bare: true
  })).pipe(gulp.dest(base_dir + "/app/"));
});

gulp.task('css', function() {
  var css, file;
  css = ["jquery.mobile-1.1.0.min.css", "jquery.mobile.datebox.min.css", "jquery.tagit.css", "tablesorter.css", "jquery.dataTables.css", "dataTables.tableTools.min.css", "designview.css", "galaxytab.css", "pivot.css"];
  css = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = css.length; _i < _len; _i++) {
      file = css[_i];
      _results.push(base_dir + "/css/" + file);
    }
    return _results;
  })();
  return gulp.src(css).pipe(cssmin()).pipe(concat("style.min.css")).pipe(gulp.dest(base_dir + "/css/"));
});

gulp.task('libs', function() {
  var file, libs;
  libs = ["d3.v3.min.js", "jquery-2.1.0.min.js", "jquery-migrate-1.2.1.min.js", "jquery-ui.js", "pivot.js", "d3_renderers.js", "underscore-min.js", "backbone-min.js", "jquery.couch.js", "backbone-couchdb.js", "jqm-config.js", "jquery.mobile-1.1.0.min.js", "jquery.mobile.datebox.min.js", "jqm.autoComplete.min-1.3.js", "handlebars.js", "form2js.js", "js2form.js", "jquery.toObject.js", "inflection.js", "jquery.dateFormat-1.0.js", "table2CSV.js", "jquery.tablesorter.min.js", "jquery.dataTables.min.js", "dataTables.tableTools.min.js", "picnet.table.filter.min.js", "jquery.table-filter.min.js", "tag-it.js", "moment.min.js", "jquery.cookie.js", "base64.js", "sha1.js", "coffee-script.js", "typeahead.min.js"];
  libs = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = libs.length; _i < _len; _i++) {
      file = libs[_i];
      _results.push(base_dir + "/js-libraries/" + file);
    }
    return _results;
  })();
  return gulp.src(libs).pipe(uglify()).pipe(concat("libs.min.js")).pipe(gulp.dest(base_dir + "/js/"));
});

gulp.task('app', function() {
  var app, file;
  app = ["config.js", "models/User.js", "models/Config.js", "models/Question.js", "models/QuestionCollection.js", "models/Result.js", "models/ResultCollection.js", "models/Sync.js", "models/LocalConfig.js", "models/Message.js", "models/MessageCollection.js", "models/Help.js", "views/LoginView.js", "views/DesignView.js", "views/QuestionView.js", "views/MenuView.js", "views/ResultsView.js", "views/ResultSummaryEditorView.js", "views/SyncView.js", "views/ManageView.js", "views/LocalConfigView.js", "views/ReportView.js", "views/CaseView.js", "views/UsersView.js", "views/MessagingView.js", "views/HelpView.js", "app.js"];
  app = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = app.length; _i < _len; _i++) {
      file = app[_i];
      _results.push(base_dir + "/" + file);
    }
    return _results;
  })();
  return gulp.src(app).pipe(uglify()).pipe(concat("app.min.js")).pipe(gulp.dest(base_dir + "/js/"));
});

gulp.task('default', ['coffee', 'libs', 'css', 'app']);

//# sourceMappingURL=Gulpfile.js.map
