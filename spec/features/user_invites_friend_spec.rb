require 'spec_helper'

feature 'User invites friend' do
  scenario 'User successfully invites friend and invitation is accepted', { js: true, vcr: true } do
    jacky = Fabricate(:user)
    sign_in(jacky)

    sleep(1)
    invite_a_friend
    friend_accepts_invitation
    sleep(3)
    friend_signs_in

    friend_should_follow(jacky)
    inviter_should_follow_friend(jacky)

    clear_email
  end

  def invite_a_friend
    visit new_invitation_path
    fill_in 'Friend\'s Name', with: 'John L'
    fill_in 'Friend\'s email address', with: 'john@example.com'
    fill_in 'Message', with: 'Hello please join this site.'
    click_button 'Send Invitation'
    sign_out
  end

  def friend_accepts_invitation
    open_email 'john@example.com'
    current_email.click_link 'Accept this invitation'

    fill_in 'Password', with: 'password'
    fill_in 'Full Name', with: 'John L'
    fill_in 'Credit Card Number', with: '4242424242424242'
    fill_in 'Security Code', with: '123'
    select '7 - July', from: 'date_month'
    select '2020', from: 'date_year'
    click_button 'Sign Up'
  end

  def friend_signs_in
    fill_in 'Email Address', with: 'john@example.com'
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
  end

  def friend_should_follow(user)
    click_link 'People'
    expect(page).to have_content(user.full_name)
    sign_out
  end

  def inviter_should_follow_friend(inviter)
    sign_in(inviter)
    click_link 'People'
    expect(page).to have_content 'John L'
  end
end
