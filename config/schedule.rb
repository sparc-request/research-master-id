every 1.hour, :roles => [:app] do
  rake 'update_from_sparc'
end


every 1.day, at: ["1:05 am", "2:05 am", "3:05 am", "4:05 am", "5:05 am", "6:05 am", "7:05 am", "8:05 am", "9:05 am", "10:05 am", "11:05 am", "12:05 pm", "1:05 pm", "2:05 pm", "3:05 pm", "4:05 pm", "5:05 pm", "6:05 pm", "7:05 pm", "8:05 pm", "9:05 pm", "10:05 pm", "11:05 pm", "12:05 am"], :roles => [:app] do
  rake 'update_from_eirb'
end

every 1.day, at: ['10:40 pm'], :roles => [:app] do
  rake 'update_from_coeus'
end
