$ ->
  $('#q_pi_name_cont').typeahead {
    minLength: 2
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 2000
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#q_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)

  $('#q_primary_pi_name_cont').typeahead {
    minLength: 2
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

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').typeahead {
      minLength: 2
      highlight: true
      hint: true
    },
      display: 'display_name'
      limit: 2000
      source: (query, syncResults, asyncResults) ->
        $.get "/directories.json?name=#{$('#research_master_pi_name').val()}", (data) ->
          asyncResults(data)

