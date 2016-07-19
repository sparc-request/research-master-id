$ ->
  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    if $('.field_with_errors') > 0
      $('.submit').addClass('disabled').trigger('change')
    else
      $('.submit').removeClass('disabled').trigger('change')
