class FixUserNameFields < ActiveRecord::Migration[5.2]
  def change
    users = User.all 

    users.each do |user|
      if user.name.blank?
        if user.middle_initial.present?
          user.update(name: "#{user.first_name} #{user.middle_initial} #{user.last_name}")
        else
          user.update(name: "#{user.first_name}  #{user.last_name}")
        end
      end
    end
  end
end
