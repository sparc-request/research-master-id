$ ->
  primary_pis = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name', 'department')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    prefetch: '/primary_pis.json'
    remote:
      url: '/primary_pis.json'
  )
  $('#q_pi_name_cont').typeahead {
    minLength: 1
    highlight: true
    hint: true
  },
    name: 'primary-pis'
    display: 'name'
    source: primary_pis

  $('#q_primary_pi_name_cont').typeahead {
    minLength: 1
    highlight: true
    hint: true
  },
    name: 'primary-pis'
    display: 'name'
    source: primary_pis

  $('#newResearchMasterModal').on 'shown.bs.modal', ->
    $('#research_master_pi_name').typeahead {
      minLength: 1
      highlight: true
      hint: true
    },
      name: 'primary-pis'
      display: 'name'
      source: primary_pis

    $('#research_master_pi_name').on 'typeahead:select', (ev, selection) ->
      $('#research_master_department').val(selection.department)


