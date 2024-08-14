class AddSubmissionTypeAndIrbReviewRequestToProtocols < ActiveRecord::Migration[5.2]
  def up
    add_column :protocols, :submission_type, :string
    add_column :protocols, :irb_review_request, :string
  end

  def down
    remove_column :protocols, :submission_type
    remove_column :protocols, :irb_review_request
  end
end
