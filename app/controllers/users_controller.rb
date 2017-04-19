class UsersController < ApplicationController
  before_filter :require_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit!)
    result = UserSignup.new(@user).sign_up(params[:stripeToken], params[:invitation_token])

    if result.successful?
      flash[:success] = 'Thank you for registering. Please sign in now.'
      redirect_to sign_in_path
    else
      flash[:error] = result.error_message
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new_with_invitation_token
    invitation = Invitation.where(token: params[:token]).first
    if invitation
      @invitation_token = invitation.token
      @user = User.new(email: invitation.recipient_email)
      render :new
    else
      redirect_to expired_token_path
    end
  end
end
