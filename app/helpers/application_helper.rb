module ApplicationHelper

  def bootstrap_class_for(flash_type)
    { success: "alert-success", error: "alert-danger", alert: "alert-danger", notice: "alert-success" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message
            end)
    end
    nil
  end

  def display_research_type(type)
    if type == 'basic_science_research'
      return 'Basic Science Research'
    elsif type == 'clinical_research_billable'
      return 'Clinical Science (Billable)'
    elsif type == 'clinical_research_non_billable'
      return 'Clinical Science (Non-billable)'
    end
  end

  def display_system_color(system)
    if system == "SPARC"
      return content_tag(:span,'', class: 'glyphicon glyphicon-stop text-primary')
    elsif system == "EIRB"
      return content_tag(:span,'', class: 'glyphicon glyphicon-stop text-success')
    elsif system == "COEUS"
      return content_tag(:span,'', class: 'glyphicon glyphicon-stop text-danger')
    end
  end

  def display_all_system_colors(research_master)
    returning_html = content_tag(:span)

    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-primary', data: { toggle: 'tooltip' }, title: 'SPARC') if research_master.sparc_protocol_id?
    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-success', data: { toggle: 'tooltip' }, title: 'EIRB') if research_master.eirb_protocol_id?
    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-danger', data: { toggle: 'tooltip' }, title: 'COEUS') if research_master.coeus_protocols.any?

    returning_html
  end

end
