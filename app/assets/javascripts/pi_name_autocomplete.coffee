$ ->
  $('#q_pi_name_cont').typeahead {
    minLength: 1
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 20
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#q_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)

  $('#q_primary_pi_name_cont').typeahead {
    minLength: 1
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 20
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_primary_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#q_primary_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').typeahead {
      minLength: 1
      highlight: true
      hint: true
    },
      display: 'display_name'
      limit: 20
      source: (query, syncResults, asyncResults) ->
        $.get "/directories.json?name=#{$('#research_master_pi_name').val()}", (data) ->
          asyncResults(data)


    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $(this).typeahead('val', selection.name)
      $('#pi_name').val(selection.name)
      $('#pi_email').val(selection.email)


