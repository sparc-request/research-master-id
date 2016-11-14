$ ->
  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    options =
      url: '/primary_pis.json'
      getValue: 'name'
      list:
        match:
          enabled: true
        onChooseEvent: ->
          idValue = $('#research_master_pi_name').getSelectedItemData().id
          $('#identity_id').val(idValue).trigger('change')

    $('#research_master_pi_name').easyAutocomplete(options)
