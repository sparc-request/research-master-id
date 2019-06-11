$ ->
  $(document).ajaxError (e, data) ->
    $('.research-master-form').renderFormErrors('research_master', data.responseJSON.error)

  $('#ResearchMasterModal').on 'shown.bs.modal', ->
    if $('#research_master_pi_name').val().length < 1 ||
       $('#research_master_pi_name').val() == $('#research_master_pi_name').attr('placeholder')
      $('.submit-rm-record').prop('disabled', true)

    $('.reset-pi-name').on 'click', ->
      unless $(this).attr("disabled") == 'disabled'
        $('#pi_name').val('')
        $('#pi_email').val('')
        $('#research_master_pi_name').prop('disabled', false)
        $('#research_master_pi_name').val('')
        $('#research_master_pi_name').typeahead('val','')
        $('#pi_department').val('')
        $('#pi_department').prop('disabled', false)
        $('.submit-rm-record').prop('disabled', true)

    $('#research_master_pi_name').on 'blur', ->
      if $(this).val() == ''
        $('.submit-rm-record').prop('disabled', true)

    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $(this).typeahead('val', selection.name)
      $('#pi_name').val(selection.name)
      $('#pi_netid').val(selection.netid)
      $('#pi_email').val(selection.email)
      $('#pi_first_name').val(selection.first_name)
      $('#pi_last_name').val(selection.last_name)
      $('#pi_middle_initial').val(selection.middle_initial)
      $('#pi_pvid').val(selection.pvid)
      if selection.department != null
        $('#pi_department').val(selection.department)
      if selection.prism_user
        $('#pi_department').prop('disabled', true)
      $('#research_master_pi_name').prop('disabled', true)
      $('.submit-rm-record').prop('disabled', false)

    $('.research-master-form').bind 'submit', ->
      $(this).find(':input').not('.eirb_locked').prop('disabled', false)

