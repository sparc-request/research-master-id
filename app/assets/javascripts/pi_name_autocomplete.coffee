$ ->
  $('#q_pi_name_cont').typeahead {
    minLength: 4
    highlight: true
    hint: true
  },
    display: 'name'
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#q_primary_pi_name_cont').typeahead {
    minLength: 4
    highlight: true
    hint: true
  },
    display: 'name'
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_primary_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').typeahead {
      minLength: 4
      highlight: true
      hint: true
    },
      display: 'name'
      source: (query, syncResults, asyncResults) ->
        $.get "/directories.json?name=#{$('#research_master_pi_name').val()}", (data) ->
          asyncResults(data)

    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $('#research_master_department').val(selection.department)


