$ ->
  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    options =
      url: '/pi_names.json'
      getValue: 'full_name'
      list:
        match:
          enabled: true
        onChooseEvent: ->
          deptValue = $('#research_master_pi_name').getSelectedItemData().department
          idValue = $('#research_master_pi_name').getSelectedItemData().id
          $('#research_master_department').val(deptValue).trigger('change')
          $('#identity_id').val(idValue).trigger('change')

    $('#research_master_pi_name').easyAutocomplete(options)
