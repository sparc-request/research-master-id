$('#ResearchMasterModal').modal('hide')
$("#research_master_<%= j @rmid_id.to_s %>").remove()
swal 'Deleted', 'Research Master record has been deleted', 'success'
