$ ->
  protocols = gon.protocols
  $('form#search-protocols').on 'change', ->
    idInput = $('#protocol_id').val()
    $('#search').on 'click', ->
      result = JSON.search(protocols, "//*[id=#{idInput.toString()}]")
      $.ajax
        type: 'GET'
        url: '/protocols'
        contentType: 'application/json'
        dataType: 'json'
        data: JSON.stringify(result)

