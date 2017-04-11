class InvitationsController < ApplicationController
  before_action :require_user

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(params.require(:invitation).permit(:recipient_name, :recipient_email, :message).merge!(inviter_id: current_user.id))
    if @invitation.save
      AppMailer.send_invitation_email(@invitation).deliver
      flash[:success] = "You have successfully sent an invitation to #{@invitation.recipient_name}"
      redirect_to new_invitation_path
    else
      flash[:error] = 'Please check your inputs'
      render :new
    end
  end
end
