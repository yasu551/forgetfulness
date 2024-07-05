class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= User.find_by!(name: 'yasu')
  end
  helper_method :current_user
end
