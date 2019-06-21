$ ->
  $('#q_pi_name_cont').typeahead( {
    minLength: 3
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 2000
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_pi_name_cont').val()}", (data) ->
        asyncResults(data)
  ).on('typeahead:asyncrequest', ->
    $('.spinner').show()
  ).on('typeahead:asynccancel typeahead:asyncreceive', ->
    $('.spinner').hide()
  )

  $('#q_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)


  ##This doesn't seem to exist anywhere in the application...?
  $('#q_primary_pi_name_cont').typeahead {
    minLength: 3
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 2000
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_primary_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#q_primary_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)
  ##

  $('#research_master_modal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').typeahead( {
      minLength: 3
      highlight: true
      hint: true
    },
      display: 'display_name'
      limit: 2000
      source: (query, syncResults, asyncResults) ->
        $.get "/directories.json?name=#{$('#research_master_pi_name').val()}", (data) ->
          asyncResults(data)
    ).on('typeahead:asyncrequest', ->
      $('.spinner').show()
    ).on('typeahead:asynccancel typeahead:asyncreceive', ->
      $('.spinner').hide()
    )
