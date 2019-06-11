$('#ResearchMasterModal').modal('show')
$('.notification-button').prop('disabled', 'true')
$('#ResearchMasterModal .modal-dialog').html("<%= j render 'form', research_master: @research_master %>")
