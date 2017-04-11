class PasswordResetsController < ApplicationController
  def show
    user = User.where(token: params[:id]).first
    if user
      @token = user.token
    else
      redirect_to expired_token_path
    end
  end

  def create
    user = User.find_by_token(params[:token])
    if user
      user.password = params[:password]
      user.generate_token
      user.save
      flash[:success] = 'Your password was successfully reset!'
      redirect_to sign_in_path
    else
      redirect_to expired_token_path
    end
  end
end
