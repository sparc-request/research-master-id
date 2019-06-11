$('#ResearchMasterModal').modal('hide')
$('.research-master-records').html("<%= j render 'research_master_index_table', research_masters: @research_masters %>")
swal {
  title: 'RMID Created'
  text: "Research Master record created (<strong>Research Master ID: <%= @research_master.id %></strong>)"
  type: 'success'
  html: true
}
