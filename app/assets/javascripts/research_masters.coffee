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

  $(document).on 'click', '.admin-rm-row', ->
    id = $(this).data('id')
    $.ajax
      type: 'GET'
      url: "/admin/research_masters/#{id}"

  $(document).on 'click', '#show_more', ->
    $('#optional-search-fields').toggle()
    if Cookies.get('showMoreCookie') == undefined
      addCookie('showMoreCookie', 1)
    else
      removeCookie('showMoreCookie')

  $(document).on 'change', 'select#reason', ->
    if $(this).val() == ''
      ##Disable submit
      $('input.reason_submit').attr("disabled", true)
    else
      ##Enable submit
      $('input.reason_submit').removeAttr("disabled")
