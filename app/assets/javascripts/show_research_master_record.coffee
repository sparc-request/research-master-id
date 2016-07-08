$ ->
  $('.research-master-record').on 'click', ->
    id = $(this).data('id')
    $.ajax
      type: 'GET'
      url: "/research_masters/#{id}"

