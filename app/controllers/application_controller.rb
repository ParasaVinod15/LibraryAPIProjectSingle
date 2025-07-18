class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    current_user&.admin?
  end

  def require_login
    redirect_to login_path, alert: "Please log in" unless logged_in?
  end

  def require_admin
    redirect_to login_path, alert: "Admins only" unless admin?
  end
end
