addCookie = (name, value) ->
  Cookies.set(name, value)

removeCookie = (name) ->
  Cookies.remove(name)

$ ->
  $("[data-toggle='tooltip']").tooltip()

  if Cookies.get('showMoreCookie') == '1'
    $('#optional-search-fields').show()
    $('#show_more').attr('checked', 'checked')

  $(document).on 'click', '.research-master', ->
    id = $(this).data('id')
    $.ajax
      type: 'GET'
      url: "/research_masters/#{id}"

  $(document).on 'click', '#show_more', ->
    $('#optional-search-fields').toggle()
    if Cookies.get('showMoreCookie') == undefined
      addCookie('showMoreCookie', 1)
    else
      removeCookie('showMoreCookie')
