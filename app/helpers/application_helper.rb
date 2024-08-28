# Copyright © 2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
    elsif system == "CAYUSE"
      return content_tag(:span,'', class: 'glyphicon glyphicon-stop text-warning')
    end
  end

  def display_all_system_colors(research_master)
    returning_html = content_tag(:span)

    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-primary', data: { toggle: 'tooltip' }, title: 'SPARC') if research_master.sparc_protocol_id?
    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-success', data: { toggle: 'tooltip' }, title: 'EIRB') if research_master.eirb_protocol_id?
    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-danger', data: { toggle: 'tooltip' }, title: 'COEUS') if research_master.coeus_protocols.any?
    returning_html += content_tag(:span,'', class: 'glyphicon glyphicon-stop text-warning', data: { toggle: 'tooltip' }, title: 'CAYUSE') if research_master.cayuse_protocols.any?

    returning_html
  end

  def research_type_options_hash
    {
      "Non-Clinical Research" => [
        ["Basic Science Research", "basic_science_research", title: t(:research_masters)[:new][:tooltips][:basic_science]] ],
      "Clinical Research" => [
        ["Clinical Science (Billable)", "clinical_research_billable", title: t(:research_masters)[:new][:tooltips][:clinical_billable]],
        ["Clinical Science (Non-billable)", "clinical_research_non_billable", title: t(:research_masters)[:new][:tooltips][:clinical_non_billable]] ]
    }
  end

  def format_date(date)
    date.strftime("%m/%d/%Y") if date
  end
end
