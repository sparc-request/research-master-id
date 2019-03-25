$('#newResearchMasterModal').modal('show')
$('#newResearchMasterModal .modal-dialog').html("<%= j render 'form' %>")
$("#newResearchMasterModal [data-toggle='tooltip']").tooltip()
