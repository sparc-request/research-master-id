$('#newResearchMasterModal').modal('show')
$('#newResearchMasterModal .modal-body').html("<%= j render 'form' %>")
$("[data-toggle='tooltip']").tooltip()
