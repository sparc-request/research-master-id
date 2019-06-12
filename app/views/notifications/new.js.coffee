$('#research_master_modal').modal('show')
$('.notification-button').prop('disabled', 'true')
$('#research_master_modal .modal-dialog').html("<%= j render 'form', research_master: @research_master %>")
