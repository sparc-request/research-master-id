module ApplicationHelper

  def bootstrap_class_for(flash_type)
    { success: "alert-success", error: "alert-danger", alert: "alert-danger", notice: "alert-success" }[flash_type.to_sym] || flash_type.to_s
  end

  def logged_in identity
    content_tag(:span, "#{t(:navbar)[:logged_in_msg]} #{current_identity.full_name} (#{current_identity.email})", class: "logged-in-as", "aria-hidden" => "true")
    puts "*" * 20
    puts current_identity
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
end
