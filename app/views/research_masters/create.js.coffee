$('#research_master_modal').modal('hide')
swal {
  title: 'RMID Created'
  text: "Research Master record created (<strong>Research Master ID: <%= @research_master.id %></strong>)"
  type: 'success'
  html: true
}
