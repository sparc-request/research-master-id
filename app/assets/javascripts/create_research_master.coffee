$ ->
  $(document).ajaxError (e, data) ->
    $('.research-master-form').renderFormErrors('research_master', data.responseJSON.error)

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    $('.submit-rm-record').prop('disabled', true)

    $('.reset-pi-name').on 'click', ->
      $('.submit-rm-record').prop('disabled', true)
      $('#research_master_pi_name').prop('disabled', false)

    $('#research_master_pi_name').on 'blur', ->
      if $(this).val() == ''
        $('.submit-rm-record').prop('disabled', true)

    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $(this).typeahead('val', selection.name)
      $('#pi_name').val(selection.name)
      $('#pi_email').val(selection.email)
      $('#research_master_pi_name').prop('disabled', true)
      $('.submit-rm-record').prop('disabled', false)

