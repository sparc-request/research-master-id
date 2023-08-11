# Copyright © 2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

$ ->
  $(document).ajaxError (e, data) ->
    $('.research-master-form').renderFormErrors('research_master', data.responseJSON.error)

  $('#research_master_modal').on 'shown.bs.modal', ->
    if $('#research_master_pi_name').val().length < 1 ||
       $('#research_master_pi_name').val() == $('#research_master_pi_name').attr('placeholder')
      $('.submit-rm-record').prop('disabled', true)

    $('.reset-pi-name').on 'click', ->
      unless $(this).attr("disabled") == 'disabled'
        $('#pi_name').val('')
        $('#pi_email').val('')
        $('#research_master_pi_name').prop('disabled', false)
        $('#research_master_pi_name').val('')
        $('#research_master_pi_name').typeahead('val','')
        $('#pi_department').val('')
        $('#pi_department').prop('disabled', false)
        $('.submit-rm-record').prop('disabled', true)
        $(this).closest('.form-group').removeClass('has-error')
        $('#label_error_message').hide()

    $('#research_master_pi_name').on 'blur', ->
      if $(this).val() == ''
        $('.submit-rm-record').prop('disabled', true)
        $(this).closest('.form-group').removeClass('has-error')
        $('#label_error_message').hide()
      if($('#pi_name').val() != $(this).val())
        $(this).closest('.form-group').addClass('has-error')
        if $("input[name='research_master[search_term]']:checked").val() == 'name'
          error_text = 'Select the PI Name from the dropdown'
        else if $("input[name='research_master[search_term]']:checked").val() == 'email'
          error_text = "Select the PI Email from the dropdown"
        else if $("input[name='research_master[search_term]']:checked").val() == 'netid'
          error_text = 'Select the PI Net ID from the dropdown'
        $('#label_error_message').show().html(error_text)

    $("input[name='research_master[search_term]']").on 'change', ->
      if $("input[name='research_master[search_term]']:checked").val() == 'name'
        error_text = 'Select the PI Name from the dropdown'
      else if $("input[name='research_master[search_term]']:checked").val() == 'email'
        error_text = "Select the PI Email from the dropdown"
      else if $("input[name='research_master[search_term]']:checked").val() == 'netid'
        error_text = 'Select the PI Net ID from the dropdown'
      $('#label_error_message').html(error_text)


    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $(this).typeahead('val', selection.name)
      $('#pi_name').val(selection.name)
      $('#pi_netid').val(selection.netid)
      $('#pi_email').val(selection.email)
      $('#pi_first_name').val(selection.first_name)
      $('#pi_last_name').val(selection.last_name)
      $('#pi_middle_initial').val(selection.middle_initial)
      $('#pi_pvid').val(selection.pvid)
      if selection.department != null
        $('#pi_department').val(selection.department)
      if selection.interfolio_user
        $('#pi_department').prop('disabled', true)
      $('#research_master_pi_name').prop('disabled', true)
      $('.submit-rm-record').prop('disabled', false)
      $(this).closest('.form-group').removeClass('has-error')
      $('#label_error_message').hide()

    $('.research-master-form').bind 'submit', ->
      $(this).find(':input').not('.eirb_locked').prop('disabled', false)

