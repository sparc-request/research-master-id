$ ->
  $('#protocol-table').on 'change', ->
    if $('#protocol-table input:checkbox:checked').length > 0
      $('a.associated-record').removeClass('disabled').trigger('change')
      $('a.create-research-master').addClass('disabled').trigger('change')
    else
      $('a.associated-record').addClass('disabled').trigger('change')
      $('a.create-research-master').removeClass('disabled').trigger('change')
    sparc_id = $('#protocol-table .sparc-protocols input:checkbox:checked').val()
    eirb_id = $('#protocol-table .eirb-protocols input:checkbox:checked').val()
    $('.associated-record').prop('href', "/research_masters/new?sparc_id=#{sparc_id}&eirb_id=#{eirb_id}")

  validateProtocol =  (type, id) ->
    protocol_count = $("#{type} input:checkbox:checked").length
    if protocol_count > 1
      swal('Error', 'You can not associate more than one record of the same type.', 'error')
      $("#protocol_#{id}").prop('checked', false)


  $('.sparc-protocols input:checkbox').on 'change', ->
    validateProtocol('.sparc-protocols', $(this).val())

  $('.eirb-protocols input:checkbox').on 'change', ->
    validateProtocol('.eirb-protocols', $(this).val())
