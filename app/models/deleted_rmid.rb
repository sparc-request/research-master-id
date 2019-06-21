class DeletedRmid < ApplicationRecord
  belongs_to :user
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :pi, class_name: 'User', foreign_key: 'pi_id'
end
