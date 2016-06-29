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
          $('#research_master_department').val(deptValue).trigger('change')

    $('#research_master_pi_name').easyAutocomplete(options)
