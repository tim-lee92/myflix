class AdminsController < ApplicationController
  before_action :require_user
  before_action :require_admin

  private

  def require_admin
    if !current_user.admin?
      flash[:error] = 'You do not have the correct permissions.'
      redirect_to home_path
    end
  end
end
