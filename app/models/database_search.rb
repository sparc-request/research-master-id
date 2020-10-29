class DatabaseSearch

  def info_query(name_string)
    users             = User.all
    user_info         = []

    users.each do |user|
      if (user.email != nil) && (user.name != nil) && (user.net_id != nil)
        if user.email.include?(name_string) || user.net_id.include?(name_string) || user.name.downcase.include?(name_string)

          entry_info = { name: nil, email: nil, netid: nil}

          entry_info[:name] = user.name
          entry_info[:email] = user.email
          entry_info[:netid] = user.net_id

          user_info << entry_info
        end
      end
    end

    user_info.sort_by{ |info| info[:name] }
  end
end