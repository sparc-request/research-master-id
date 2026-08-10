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

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    if ENV['SELENIUM_URL'].present?
      
      # Tell Capybara's internal test server to listen on all interfaces (0.0.0.0)
      Capybara.server_host = '0.0.0.0'
      # Assign a specific port for the test server so it doesn't hit dev on 3002
      Capybara.server_port = 4000
      # Route Selenium to hit the Capybara test server!
      Capybara.app_host = "http://rmid_web:#{Capybara.server_port}"
      
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless') if ENV['HEADLESS'].present?
      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--disable-gpu') 
      options.add_argument('--window-size=1920,1080')

      driven_by(:selenium, using: :chrome, options: {
        browser: :remote,
        url: ENV['SELENIUM_URL'],
        options: options 
      })
    else
      # LOCAL OR GITHUB ACTIONS EXECUTION: Use the native machine driver
      if ENV['CI'].present? || ENV['HEADLESS'].present?
        driven_by :selenium_chrome_headless
      else
        driven_by :selenium_chrome
      end
    end
  end
end
