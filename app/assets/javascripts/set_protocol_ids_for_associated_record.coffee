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
  $('#protocol-table').on 'change', ->
    if $('#protocol-table input:checkbox:checked').length > 0
      $('a.associate-protocols').removeClass('disabled').trigger('change')
      $('a.create-research-master').addClass('disabled').trigger('change')
    else
      $('a.associate-protocols').addClass('disabled').trigger('change')
      $('a.create-research-master').removeClass('disabled').trigger('change')
    sparc_id = $('#protocol-table .sparc-protocols input:checkbox:checked').val()
    eirb_id = $('#protocol-table .eirb-protocols input:checkbox:checked').val()
    $('.associate-protocols').prop('href', "/research_masters/new?sparc_id=#{sparc_id}&eirb_id=#{eirb_id}")

  validateProtocol =  (type, id) ->
    protocol_count = $("#{type} input:checkbox:checked").length
    if protocol_count > 1
      swal('Error', 'You can not associate more than one record of the same type.', 'error')
      $("#protocol_#{id}").prop('checked', false)


  $('.sparc-protocols input:checkbox').on 'change', ->
    validateProtocol('.sparc-protocols', $(this).val())

  $('.eirb-protocols input:checkbox').on 'change', ->
    validateProtocol('.eirb-protocols', $(this).val())
