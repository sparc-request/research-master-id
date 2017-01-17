$('#newResearchMasterModal').modal('hide')
$('.research-master-records').html("<%= j render 'research_master_index_table', research_masters: @research_masters %>")
swal('Success', 'Research Master record updated', 'success')
