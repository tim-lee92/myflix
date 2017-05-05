require 'spec_helper'

feature 'user signs in' do
  scenario 'with valid email and password' do
    jacky = Fabricate(:user)
    sign_in(jacky)
    # page.should have_content jacky.full_name
    expect(page).to have_content(jacky.full_name)
  end

  scenario 'with deactivated user' do
    lily = Fabricate(:user, active: false)
    sign_in(lily)
    expect(page).not_to have_content(lily.full_name)
    expect(page).to have_content('Your account has been suspended. Please contact customer service.')
  end
end
