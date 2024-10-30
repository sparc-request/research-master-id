task fix_duplicate_eirb_protocols: :environment do
  Protocol.auditing_enabled = false

  protocols_with_eirb_id = Protocol.where.not(eirb_id: nil)
  total_before = protocols_with_eirb_id.count
  unique_eirb_ids = protocols_with_eirb_id.distinct.count(:eirb_id)
  puts "Total protocols with eirb_id: #{total_before}"
  puts "Total unique eirb_ids: #{unique_eirb_ids}"

  begin
    protocols_with_eirb_id.group(:eirb_id).having('count(*) > 1').pluck(:eirb_id).each do |eirb_id|
      protocols = Protocol.where(eirb_id: eirb_id).order(:created_at)
      master = protocols.max_by(&:updated_at)
      oldest = protocols.first.created_at

      Protocol.transaction do
        begin
          master.update!(type: 'EIRB', created_at: oldest)
          protocols.where.not(id: master.id).destroy_all
        rescue => e
          Rails.logger.error "Error updating protocol #{master.id} with eirb_id: #{eirb_id}: #{e.message}"
          raise ActiveRecord::Rollback
        end
      end
    end

    protocols_with_eirb_id.group(:eirb_id).having('count(*) = 1').each do |protocol|
      begin
        protocol.update(type: 'EIRB')
      rescue => e
        Rails.logger.error "Error updating protocol #{protocol.id} with eirb_id: #{protocol.eirb_id}: #{e.message}"
      end
    end
  rescue => e
    Rails.logger.error "Error updating protocols: #{e.message}"
  ensure
    Protocol.auditing_enabled = true
  end

  total_after = Protocol.where.not(eirb_id: nil).count
  duplicates_removed = total_before - total_after

  puts "Total protocols with eirb_id after removing duplicates: #{total_after}"
  puts "#{duplicates_removed} duplicates removed"
  puts "Total eirb protocols should now match total unique eirb_ids -
    Total eirb protocols: #{total_after}
    Total unique eirb_id: #{unique_eirb_ids}"
end
