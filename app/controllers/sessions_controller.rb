class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to home_path
    else
      render 'pages/new'
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      if user.active?
        session[:user_id] = user.id
        redirect_to home_path, notice: 'You are signed in.'
      else
        flash[:error] = 'Your account has been suspended. Please contact customer service.'
        redirect_to sign_in_path
      end
    else
      flash[:error] = 'Your email or password was invalid'
      redirect_to sign_in_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'You have signed out'
  end
end
