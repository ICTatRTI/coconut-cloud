class ReportView extends Backbone.View
  el: '#content'

  events:
    "change #reportOptions": "update"
    "change #summaryField": "summarize"
    "change #aggregateBy": "update"
    "click #toggleDisaggregation": "toggleDisaggregation"

  update: =>
    reportOptions =
      startDate: $('#start').val()
      endDate: $('#end').val()
      reportType: $('#report-type :selected').text()
      question: $('#selected-question :selected').text()
      aggregateBy: $("#aggregateBy :selected").text()

    _.each @locationTypes, (location) ->
      reportOptions[location] = $("##{location} :selected").text()

    url = "reports/" + _.map(reportOptions, (value, key) ->
      "#{key}/#{escape(value)}"
    ).join("/")

    Coconut.router.navigate(url,true)

  render: (options) =>

    @reportType = options.reportType || "results"
    @startDate = options.startDate || moment(new Date).subtract('days',14).format("YYYY-MM-DD")
    @endDate = options.endDate || moment(new Date).format("YYYY-MM-DD")
    @question = unescape(options.question)
    @aggregateBy = options.aggregateBy || "District"

    @$el.html "
      <style>
        table.results th.header, table.results td{
          font-size:150%;
        }

      </style>

      <table id='reportOptions'></table>
      <div id='report'></div>
    "

    Coconut.questions.fetch
      success: =>
        $("#reportOptions").append @formFilterTemplate(
          id: "question"
          label: "Question"
          form: "
              <select id='selected-question'>
                #{
                  Coconut.questions.map( (question) =>
                    "<option #{if question.label() is @question then "selected='true'" else ""}>#{question.label()}</option>"
                  ).join("")
                }
              </select>
            "
        )

        $("#reportOptions").append @formFilterTemplate(
          id: "start"
          label: "Start Date"
          form: "<input id='start' type='date' value='#{@startDate}'/>"
        )

        $("#reportOptions").append @formFilterTemplate(
          id: "end"
          label: "End Date"
          form: "<input id='end' type='date' value='#{@endDate}'/>"
        )

        $("#reportOptions").append @formFilterTemplate(
          id: "report-type"
          label: "Report Type"
          form: "
          <select id='report-type'>
            #{
              _.map(["results","spreadsheet","pivotTable","summarytables"], (type) =>
                "<option #{"selected='true'" if type is @reportType}>#{type}</option>"
              ).join("")
            }
          </select>
          "
        )

        this[@reportType]()

        $('div[data-role=fieldcontain]').fieldcontain()
        $('select').selectmenu()
        $('input[type=date]').datebox {mode: "calbox"}


  hierarchyOptions: (locationType, location) ->
    if locationType is "region"
      return _.keys WardHierarchy.hierarchy
    _.chain(WardHierarchy.hierarchy)
      .map (value,key) ->
        if locationType is "district" and location is key
          return _.keys value
        _.map value, (value,key) ->
          if locationType is "constituan" and location is key
            return _.keys value
          _.map value, (value,key) ->
            if locationType is "shehia" and location is key
              return value
      .flatten()
      .compact()
      .value()

  mostSpecificLocationSelected: ->
    mostSpecificLocationType = "region"
    mostSpecificLocationValue = "ALL"
    _.each @locationTypes, (locationType) ->
      unless this[locationType] is "ALL"
        mostSpecificLocationType = locationType
        mostSpecificLocationValue = this[locationType]
    return {
      type: mostSpecificLocationType
      name: mostSpecificLocationValue
    }

  formFilterTemplate: (options) ->
    "
        <tr>
          <td>
            <label style='display:inline' for='#{options.id}'>#{options.label}</label> 
          </td>
          <td style='width:150%'>
            #{options.form}
            </select>
          </td>
        </tr>
    "

  viewQuery: (options) ->

    results = new ResultCollection()
    results.fetch
      question: $('#selected-question').val()
      isComplete: true
      include_docs: true
      success: ->
        results.fields = {}
        results.each (result) ->
          _.each _.keys(result.attributes), (key) ->
            results.fields[key] = true unless _.contains ["_id","_rev","question"], key
        results.fields = _.keys(results.fields)
        options.success(results)

  spreadsheet: =>
    $("#report").html "
      <table id='reportTable'>
        <thead>
          <tr/>
        </thead>
        <tbody>
        </tbody>
      </table>
    "

    
    if @endDate
      endkey = moment(@endDate).endOf("day").format("YYYY-MM-DD HH:mm:ss") # include all entries for today

    $.couch.db(Coconut.config.database_name()).view "#{Coconut.config.design_doc_name()}/results",
      startkey: [@question, @startDate or null]
      endkey: [@question, endkey or {}]
      include_docs: true
      error: (error) => console.log JSON.stringify error
      success: (results) =>
        results = results.rows
        fields = {}
        _(results).each (result) ->
          _(_(result.doc).keys()).each (key) ->
            fields[key] = true

        fields = _(fields).keys()

        $("#reportTable thead tr").html(_(fields).map (field) ->
          "<th>#{field}</th>"
        .join "")

        $("#reportTable tbody").html(_(results).map (result) ->
          "
            <tr>
              #{
                _(fields).map (field) ->
                  "<td>#{result.doc[field] or "-"}</td>"
                .join ""
              }
            </tr>
          "
        .join "")

        $("#report").css "overflow", "scroll"

        $("#reportTable").dataTable
          aaSorting: [[0,"desc"]]
          iDisplayLength: 25
          dom: 'T<"clear">lfrtip'
          tableTools:
            sSwfPath: "js-libraries/copy_csv_xls_pdf.swf"


  pivotTable: ->
    if @endDate
      endkey = moment(@endDate).endOf("day").format("YYYY-MM-DD HH:mm:ss") # include all entries for today
    $.couch.db(Coconut.config.database_name()).view "#{Coconut.config.design_doc_name()}/results",
      startkey: [@question, @startDate or null]
      endkey: [@question, endkey or {}]
      include_docs: true
      error: (error) => console.log JSON.stringify error
      success: (results) =>

          

        console.log  _(results.rows).pluck "doc",
        $("#report").pivotUI _(results.rows).pluck("doc"),
            renderers: $.extend(
              $.pivotUtilities.renderers,
              $.pivotUtilities.gchart_renderers,
              $.pivotUtilities.d3_renderers
            )

  results: ->
    
    if @endDate
      endkey = moment(@endDate).endOf("day").format("YYYY-MM-DD HH:mm:ss") # include all entries for today
    $.couch.db(Coconut.config.database_name()).view "#{Coconut.config.design_doc_name()}/results",
      startkey: [@question, @startDate or null]
      endkey: [@question, endkey or {}]
      include_docs: true
      error: (error) => console.log JSON.stringify error
      success: (results) =>
        
        @$el.append "
          <h2>#{@question}: #{results.rows.length} results for #{@startDate} - #{@endDate}</h2>
          Select another report type above for further analysis
        "


  summarytables: ->
    Coconut.resultCollection.fetch
      includeData: true
      success: =>

        fields = _.chain(Coconut.resultCollection.toJSON())
        .map (result) ->
          _.keys(result)
        .flatten()
        .uniq()
        .sort()
        .value()

        fields = _.without(fields, "_id", "_rev")
    
        @$el.append  "
          <br/>
          Choose a field to summarize:<br/>
          <select id='summaryField'>
            #{
              _.map(fields, (field) ->
                "<option id='#{field}'>#{field}</option>"
              ).join("")
            }
          </select>
        "
        $('select').selectmenu()


  summarize: ->
    field = $('#summaryField option:selected').text()

    @viewQuery
      success: (resultCollection) =>

        results = {}

        resultCollection.each (result) ->
          _.each result.toJSON(), (value,key) ->
            if key is field
              if results[value]?
                results[value]["sums"] += 1
                results[value]["resultIDs"].push result.get "_id"
              else
                results[value] = {}
                results[value]["sums"] = 1
                results[value]["resultIDs"] = []
                results[value]["resultIDs"].push result.get "_id"

        @$el.append  "
          <h2>#{field}</h2>
          <table id='summaryTable' class='tablesorter'>
            <thead>
              <tr>
                <th>Value</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              #{
                _.map( results, (aggregates,value) ->
                  "
                  <tr>
                    <td>#{value}</td>
                    <td>
                      <button id='toggleDisaggregation'>#{aggregates["sums"]}</button>
                    </td>
                    <td class='dissaggregatedResults'>
                      #{
                        _.map(aggregates["resultIDs"], (resultID) ->
                          resultID
                        ).join(", ")
                      }
                    </td>
                  </tr>
                  "
                ).join("")
              }
            </tbody>
          </table>
        "
        $("button").button()
        $("a").button()
        _.each $('table tr'), (row, index) ->
          $(row).addClass("odd") if index%2 is 1


  toggleDisaggregation: ->
    $(".dissaggregatedResults").toggle()

