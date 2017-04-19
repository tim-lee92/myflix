require 'spec_helper'

feature 'Admin adds new video' do
  scenario 'Admin successfully adds a new video' do
    admin = Fabricate(:user, admin: true)
    reality = Fabricate(:category, name: 'Reality')
    sign_in(admin)
    visit new_admin_video_path

    fill_in 'Title', with: 'Kitchen Nightmares'
    select 'Reality', from: 'Category'
    fill_in 'Description', with: 'Dirty kitchens'
    attach_file 'Large cover', 'spec/support/uploads/43643.jpg'
    attach_file 'Small cover', 'spec/support/uploads/43643.jpg'
    fill_in 'Video URL', with: 'http://example.com/my_video.mp4'
    click_button 'Add Video'

    sign_out
    sign_in

    visit video_path(Video.first)
    expect(page).to have_selector("img[src='/uploads/43643.jpg']")
    expect(page).to have_selector("a[href='http://example.com/my_video.mp4']")
  end
end
