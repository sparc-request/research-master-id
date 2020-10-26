# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

class Notifier < ActionMailer::Base

  def success(recipient, pi, rm_id)
    @pi = pi || NullUser.new
    @rm_id = rm_id
    @url = ENV.fetch('RMID_LINK')
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : recipient
    mail(
      to: address,
      subject: "Research Master Record Successfully Created (RMID: #{rm_id.id} - #{recipient})",
      from: 'donotreply@musc.edu'
    )
  end

  def removed(deleted_rmid)
    @deleted_rmid = deleted_rmid
    @pi = User.find(@deleted_rmid.pi_id)
    @creator = User.find(@deleted_rmid.creator_id)
    @remover = User.find(@deleted_rmid.user_id)
    combined_emails = (@pi.email == @creator.email ? @pi.email : [@pi.email, @creator.email])
    address = ENV.fetch('ENVIRONMENT') == 'staging' ? 'sparcrequest@gmail.com' : combined_emails
    mail(
      to: address,
      subject: "Research Master Record Removed (RMID: #{@deleted_rmid.original_id})",
      from: 'donotreply@musc.edu'
    )
  end
end
