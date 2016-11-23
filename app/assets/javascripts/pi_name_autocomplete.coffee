$ ->
  options =
    url: '/primary_pis.json'
    getValue: 'name'
    list:
      match:
        enabled: true
      onChooseEvent: ->
        idValue = $('#research_master_pi_name').getSelectedItemData().id
        $('#identity_id').val(idValue).trigger('change')

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').easyAutocomplete(options)

  $('#q_pi_name_cont').easyAutocomplete(options)
  $('#q_primary_pi_name_cont').easyAutocomplete(options)
