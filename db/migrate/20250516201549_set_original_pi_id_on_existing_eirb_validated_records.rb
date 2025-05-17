class SetOriginalPiIdOnExistingEirbValidatedRecords < ActiveRecord::Migration[5.2]
  def up
    eirb_validated_records = ResearchMaster
      .where(eirb_validated: true)
      .where.not(eirb_protocol_id: nil)
      .where.not(pi_id: nil)
      .where(original_pi_id: nil)

    puts "#{eirb_validated_records.count} records are eirb_validated with no original_pi_id."

    updated = 0
    eirb_validated_records.find_each do |rm|
      new_original_pi = rm.previous_pi_id.presence || rm.pi_id
      rm.update_column(:original_pi_id, new_original_pi)
      updated += 1
    end
    puts "#{updated} records updated with original_pi_id."
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This data backfill is based on record state at runtime and can't be reversed."
  end
end
