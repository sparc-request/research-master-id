$ ->
  $('#protocol-table').on 'change', ->
    if $('#protocol-table input:checkbox:checked').length > 0
      $('a.associated-record').removeClass('disabled').trigger('change')
    else
      $('a.associated-record').addClass('disabled').trigger('change')
    sparc_id = $('#protocol-table .sparc-protocols input:checkbox:checked').val()
    $('.associated-record').prop('href', "/research_masters/new?sparc_id=#{sparc_id}")

  $('.sparc-protocols input:checkbox').on 'change', ->
    sparc_id = $(this).val()
    sparc_protocol_count = $('.sparc-protocols input:checkbox:checked').length
    if sparc_protocol_count > 1
      alert('You can not associate more than one record of the same type.')
      $("#protocol_#{sparc_id}").prop('checked', false)

