every 4.hours, :roles => [:app] do
  rake 'update_data'
end
