require 'spec_helper'

feature 'User following' do
  scenario 'user follows and unfollows someone' do
    lily = Fabricate(:user)
    category = Fabricate(:category)
    video = Fabricate(:video, category: category)
    Fabricate(:review, user: lily, video: video)

    sign_in
    click_on_video_on_home_page(video)

    click_link lily.full_name
    click_link 'Follow'
    expect(page).to have_content(lily.full_name)

    unfollows(lily)
    expect(page).not_to have_content(lily.full_name)
  end

  def unfollows(user)
    find("a[data-method='delete']").click
  end
end
