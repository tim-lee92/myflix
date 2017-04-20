require 'spec_helper'

feature 'Admin sees payments' do
  background do
    jacky = Fabricate(:user, full_name: 'Jacky H')
    Fabricate(:payment, amount: 999, user: jacky)
  end

  scenario 'admin can see payments' do
    admin = Fabricate(:user, admin: true)
    sign_in(admin)
    visit admin_payments_path
    expect(page).to have_content('$9.99')
    expect(page).to have_content('Jacky H')
  end

  scenario 'users cannot see payments' do
    regular_user = Fabricate(:user)
    sign_in(regular_user)
    visit admin_payments_path
    expect(page).not_to have_content('$9.99')
    expect(page).not_to have_content('Jacky H')
    expect(page).to have_content('You do not have the correct permissions.')
  end
end
