class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit!)
    if @user.save
      redirect_to sign_in_path
    else
      render :new
    end
  end
end
