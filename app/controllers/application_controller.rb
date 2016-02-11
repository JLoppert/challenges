class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def api_client
    @client = SODA::Client.new({
      domain: SODA_DOMAIN,
      app_token: SODA_API_TOKEN
    })
  end
end
