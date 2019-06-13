$('#research_master_modal').modal('hide')
$("#research_master_<%= j @research_master.id.to_s %>").replaceWith("<%= j render 'research_master_row', research_master: @research_master %>")
swal('Success', 'Research Master record updated', 'success')
