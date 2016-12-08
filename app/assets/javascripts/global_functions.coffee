root = exports ? this

root.$.fn.clearFormErrors = ->
  this.find('.form-group').removeClass('has-error')
  this.find('span.help-block').remove()

root.$.fn.renderFormErrors = (modelName, errors) ->
  form = this
  this.clearFormErrors()

  $.each(errors, (field, messages) ->
    input = form.find('input, select, textarea').filter(->
      name = $(this).attr('name')
      if name
        name.match(new RegExp(modelName + '\\[' + field + '\\(?'))
    )
    input.closest('.form-group').addClass('has-error')
    input.parent().append('<span class="help-block">' + $.map(messages, (m) -> m.charAt(0).toUpperCase() + m.slice(1)).join('<br />') + '</span>')
  )
