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

every 1.hour, :roles => [:app] do
  rake 'update_from_sparc'
end

every 1.day, at: ["1:25 am", "2:25 am", "3:25 am", "4:25 am", "5:25 am", "6:25 am", "7:25 am", "8:25 am", "9:25 am", "10:25 am", "11:25 am", "12:25 pm", "1:25 pm", "2:25 pm", "3:25 pm", "4:25 pm", "5:25 pm", "6:25 pm", "7:25 pm", "8:25 pm", "9:25 pm", "10:25 pm", "11:25 pm", "12:25 am"], :roles => [:app] do
  rake 'update_from_eirb_db'
end

every 1.day, at: ['10:40 pm'], :roles => [:app] do
  rake 'update_from_coeus_db'
end

every 1.day, at: ['10:50 pm'], :roles => [:app] do
  rake 'update_from_cayuse_db'
end

every 1.hour, :roles => [:app] do
  rake 'delayed_job_monitor'
end
