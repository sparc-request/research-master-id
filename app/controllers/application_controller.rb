class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def test_exception_notifier
    raise 'This is a test. This is only a test.'
  end

  protected

  def authenticate_user!
    if user_signed_in?
      super
    else
      if ENV.fetch('ENVIRONMENT') == 'development'
        super
      else
        redirect_to user_shibboleth_omniauth_callback_path
      end
    end
  end
end

