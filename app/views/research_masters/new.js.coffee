$('#newResearchMasterModal').modal('show')
$('#newResearchMasterModal .modal-dialog').html("<%= j render 'form' %>")
$("[data-toggle='tooltip']").tooltip()
