class RenameSubmissionTypeToReviewTypeInProtocols < ActiveRecord::Migration[5.2]
  def change
    rename_column :protocols, :submission_type, :review_type
  end
end
