$ ->
  protocols = gon.protocols
  $('form#search-protocols').on 'change', ->
    idInput = $('#protocol_id').val()
  $('#search').on 'click', ->
    result = JSON.search(protocols, '//*[contains(pi_name, "Dag")]')

