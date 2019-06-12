$('#research_master_modal').modal('show')
$('#research_master_modal .modal-dialog').html("<%= j render 'form' %>")
$("#research_master_modal [data-toggle='tooltip']").tooltip()
