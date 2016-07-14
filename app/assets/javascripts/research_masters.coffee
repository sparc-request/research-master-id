$ ->
  $('.research-master-record').on 'click', ->
    id = $(this).data('id')
    $.ajax
      type: 'GET'
      url: "/research_masters/#{id}"

  # $(document).on 'click', '.remove_association', ->
  #   research_master_id = $(this).data('id')
  #   confirm = swal {  title: 'Are you sure?'
  #                     text: 'You will not be able to recover this imaginary file!'
  #                     type: 'warning'
  #                     showCancelButton: true
  #                     confirmButtonColor: '#DD6B55'
  #                     confirmButtonText: 'Yes, delete it!'
  #                     closeOnConfirm: false
  #                   }, ->
  #                     swal 'Deleted!', 'Your imaginary file has been deleted.', 'success'
  #                     return

