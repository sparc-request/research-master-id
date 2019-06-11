<% if @notification.valid? %>
$('#ResearchMasterModal').modal('hide')
swal('Success', 'Your message has been sent', 'success')
<% else %>
swal('Error', 'Your message could not be sent', 'error')
<% end %>
