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

  $(document).on 'click', '.research-master-delete', (e) ->
    e.preventDefault()
    research_master_id = $(this).data('id')
    swal {
      title: 'Delete Research Master'
      text: 'You will not be able to undo this'
      type: 'warning'
      showCancelButton: true
      confirmButtonColor: '#DD6B55'
      confirmButtonText: 'Delete'
      closeOnConfirm: false
      closeOnCancel: true
      showLoaderOnConfirm: true
    }, (confirmed) ->
      if confirmed
        $.ajax
          type: 'delete'
          url: "/research_masters/#{research_master_id}"
          success: ->
            $("#research_master_#{research_master_id}").remove()
            swal 'Deleted', 'Research Master record has been deleted', 'success'

  $(document).on 'click', '#show_more', ->
    $('#optional-search-fields').toggle()
    if Cookies.get('showMoreCookie') == undefined
      addCookie('showMoreCookie', 1)
    else
      removeCookie('showMoreCookie')

  $(document).on 'change', '#research_master_research_type_clinical_research, #research_master_research_type_basic_science_research', ->
    if $(this).val() == 'clinical_research'
      $('.musc-health-services').show()
    else
      $('.musc-health-services').hide()


