$ ->
  $('#protocol-table').on 'change', ->
    sparc_id = $('#protocol-table .sparc-protocols input:checkbox:checked').val()
    $('.associated-record').prop('href', "/research_masters/new?sparc_id=#{sparc_id}")

