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

# Preview all emails at http://localhost:3000/rails/mailers/pi_mailer
class PiMailerPreview < ActionMailer::Preview
  def notify_pis
    rm = ResearchMaster.where.not(previous_pi_id: nil).first

    if rm.nil?
      rm = ResearchMaster.first
      exisiting_pi = User.first
      current_pi = User.second || User.first
      creator = User.third || User.first
    else
      existing_pi = User.find_by(id: rm.previous_pi_id)
      current_pi = User.find_by(id: rm.pi_id)
      creator = User.find_by(id: rm.creator_id)

      existing_pi ||= User.first
      current_pi ||= User.second || User.first
      creator ||= User.third || User.first
    end

    PiMailer.notify_pis(rm, existing_pi, current_pi, creator)
  end

  def notify_pis_on_restore
    rm = ResearchMaster.where.not(previous_pi_id: nil).first

    if rm.nil?
      rm = ResearchMaster.first
      exisiting_pi = User.first
      current_pi = User.second || User.first
      creator = User.third || User.first
    else
      existing_pi = User.find_by(id: rm.previous_pi_id)
      current_pi = User.find_by(id: rm.pi_id)
      creator = User.find_by(id: rm.creator_id)

      existing_pi ||= User.first
      current_pi ||= User.second || User.first
      creator ||= User.third || User.first
    end

    PiMailer.notify_pis_on_restore(rm, existing_pi, current_pi, creator)
  end

end
