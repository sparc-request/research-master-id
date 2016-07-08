$ ->
  $('#protocol-table').on 'change', ->
    if $('#protocol-table input:checkbox:checked').length > 0
      $('a.associated-record').removeClass('disabled').trigger('change')
    else
      $('a.associated-record').addClass('disabled').trigger('change')
    sparc_id = $('#protocol-table .sparc-protocols input:checkbox:checked').val()
    $('.associated-record').prop('href', "/research_masters/new?sparc_id=#{sparc_id}")

