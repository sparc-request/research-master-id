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

  searchTermValue = () ->
    selected = ""
    search_options = $('.search-term-options')
    search_options.each ->
      if $(this).prop("checked")
        selected = $(this).val()

    return selected

  $('#q_pi_name_cont').typeahead( {
    minLength: 3
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 2000
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_pi_name_cont').val()};source=pi_name", (data) ->
        asyncResults(data)
  ).on('typeahead:asyncrequest', ->
    $('.spinner').show()
  ).on('typeahead:asynccancel typeahead:asyncreceive', ->
    $('.spinner').hide()
  )

  $('#q_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)


  ##This doesn't seem to exist anywhere in the application...?
  $('#q_primary_pi_name_cont').typeahead {
    minLength: 3
    highlight: true
    hint: true
  },
    display: 'display_name'
    limit: 2000
    source: (query, syncResults, asyncResults) ->
      $.get "/directories.json?name=#{$('#q_primary_pi_name_cont').val()}", (data) ->
        asyncResults(data)

  $('#q_primary_pi_name_cont').on 'typeahead:select', (ev, selection) ->
    $(this).typeahead('val', selection.name)
  ##

  $('#research_master_modal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').typeahead( {
      minLength: 3
      highlight: true
      hint: true
    },
      display: 'display_name'
      limit: 2000
      source: (query, syncResults, asyncResults) ->
        $.get "/directories.json?name=#{$('#research_master_pi_name').val()};search_term=#{searchTermValue()}", (data) ->
          asyncResults(data)
    ).on('typeahead:asyncrequest', ->
      $('.spinner').show()
    ).on('typeahead:asynccancel typeahead:asyncreceive', ->
      $('.spinner').hide()
    )
