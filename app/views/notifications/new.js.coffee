$('#newResearchMasterModal').modal('show')
$('.notification-button').prop('disabled', 'true')
$('#newResearchMasterModal .modal-dialog').html("<%= j render 'form', research_master: @research_master %>")
