$ ->
  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    options =
      url: '/pi_names.json'
      getValue: 'full_name'
      theme: 'square'
    $('#research_master_pi_name').easyAutocomplete(options)
