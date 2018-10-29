every 1.day, at: ['2:30 am', '6:30 am', '10:30 am', '2:30 pm', '6:30 pm', '10:30 pm'], :roles => [:app] do
  rake 'update_from_sparc'
end

every 1.day, at: ['2:35 am', '6:35 am', '10:35 am', '2:35 pm', '6:35 pm', '10:35 pm'], :roles => [:app] do
  rake 'update_from_eirb'
end

every 1.day, at: ['2:40 am', '6:40 am', '10:40 am', '2:40 pm', '6:40 pm', '10:40 pm'], :roles => [:app] do
  rake 'update_from_coeus'
end
