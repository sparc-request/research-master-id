$ ->
  $(document).on 'click', '.submit-rm', (e) ->
    e.preventDefault()
    values = {}
    $.each $('.research-master-form').serializeArray(), (i, field) ->
      values[field.name] = field.value
    $.ajax
      url: '/research_masters'
      type: 'POST'
      data: values
      error: (e, data, status, xhr) ->
        swal('Error', 'Something went wrong, check the form for details', 'error')
        $('.research-master-form').renderFormErrors('research_master', e.responseJSON.error)

