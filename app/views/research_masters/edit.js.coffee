$('#ResearchMasterModal').modal('show')
$('#ResearchMasterModal .modal-dialog').html("<%= j render 'form' %>")
$("#ResearchMasterModal [data-toggle='tooltip']").tooltip()
