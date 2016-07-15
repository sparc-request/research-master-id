$ ->
  $('.research-master').on 'click', ->
    id = $(this).data('id')
    $.ajax
      type: 'GET'
      url: "/research_masters/#{id}"

  $(document).on 'click', 'button.delete', ->
    research_master_id = $(this).data('id')
    if confirm('Are you sure you want to delete this association?')
      $.ajax
        type: 'delete'
        url: "/research_masters/#{research_master_id}"


