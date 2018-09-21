every 1.day, at: ['2:30 am', '6:30 am', '10:30 am', '2:30 pm', '6:30 pm', '10:30 pm'], :roles => [:app] do
  rake 'update_data'
end
