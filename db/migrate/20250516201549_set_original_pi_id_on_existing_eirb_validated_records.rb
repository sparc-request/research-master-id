# Copyright © 2025 MUSC Foundation for Research Development~
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
