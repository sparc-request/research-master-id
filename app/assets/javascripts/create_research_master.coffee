$ ->
  $(document).ajaxError (e, data) ->
    $('.research-master-form').renderFormErrors('research_master', data.responseJSON.error)

