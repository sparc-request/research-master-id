$ ->
  $(document).on 'click', '.clear-selection', (e) ->
    e.preventDefault()
    $(this).closest('.input-group').find('input.form-control').val('')

  $(document).on 'click', '.clear-all', (e) ->
    e.preventDefault()
    $('.clear-form').find('input.form-control').val('')
