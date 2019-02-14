$ ->
  $(document).ajaxError (e, data) ->
    $('.research-master-form').renderFormErrors('research_master', data.responseJSON.error)

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    if $('#research_master_pi_name').val().length < 1 ||
       $('#research_master_pi_name').val() == $('#research_master_pi_name').attr('placeholder')
      $('.submit-rm-record').prop('disabled', true)

    $('.reset-pi-name').on 'click', ->
      unless $(this).attr("disabled") == 'disabled'
        $('.submit-rm-record').prop('disabled', true)
        $('#research_master_pi_name').prop('disabled', false)
        $('#research_master_pi_name').val('')
        $('#research_master_department').val('')
        $('#research_master_department').prop('disabled', false)
        $('#research_master_pi_name').typeahead('val','')

    $('#research_master_pi_name').on 'blur', ->
      if $(this).val() == ''
        $('.submit-rm-record').prop('disabled', true)

    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $(this).typeahead('val', selection.name)
      $('#pi_name').val(selection.name)
      $('#pi_email').val(selection.email)
      if selection.department != null
        $('#research_master_department').val(selection.department)
        $('#research_master_department').prop('disabled', true)
      $('#research_master_pi_name').prop('disabled', true)
      $('.submit-rm-record').prop('disabled', false)

    $('.research-master-form').bind 'submit', ->
      $(this).find(':input').not('.eirb_locked').prop('disabled', false)

