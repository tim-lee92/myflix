require 'spec_helper'

feature 'user signs in' do
  scenario 'with valid email and password' do
    jacky = Fabricate(:user)
    sign_in(jacky)
    # page.should have_content jacky.full_name
    expect(page).to have_content(jacky.full_name)
  end
end
