require 'spec_helper'

feature 'User interacts with the queue' do
  scenario 'user adds and reorders videos in the queue' do
    comedies = Fabricate(:category)
    monk = Fabricate(:video, title: 'Monk', category: comedies)
    h3h3 = Fabricate(:video, title: 'h3h3', category: comedies)
    kripp = Fabricate(:video, title: 'Kripp', category: comedies)

    sign_in
    
    add_video_to_queue(h3h3)
    expect_video_to_be_in_queue(h3h3)

    visit "/videos/#{h3h3.id}"
    expect_link_not_to_be_seen('+ My Queue')

    add_video_to_queue(kripp)
    add_video_to_queue(monk)

    set_video_position(kripp, 1)
    set_video_position(h3h3, 3)
    set_video_position(monk, 2)

    click_button "Update Instant Queue"

    expect_video_position(kripp, 1)
    expect_video_position(h3h3, 3)
    expect_video_position(monk, 2)

    # visit home_path
    # find("a[href='/videos/#{kripp.id}']").click
    # click_link "+ My Queue"
    # visit home_path
    # find("a[href='/videos/#{monk.id}']").click
    # click_link "+ My Queue"

    # find("input[data-video-id='#{h3h3.id}']").set(3)
    # find("input[data-video-id='#{kripp.id}']").set(1)
    # find("input[data-video-id='#{monk.id}']").set(2)

    # within(:xpath, "//tr[contains(.,'#{kripp.title}')]") do
    #   fill_in 'queue_items[][position]', with: 1
    # end
    #
    # within(:xpath, "//tr[contains(.,'#{h3h3.title}')]") do
    #   fill_in 'queue_items[][position]', with: 3
    # end
    #
    # within(:xpath, "//tr[contains(.,'#{monk.title}')]") do
    #   fill_in 'queue_items[][position]', with: 2
    # end

    # expect(find(:xpath, "//tr[contains(.,'#{kripp.title}')]//input[@type='text']").value).to eq('1')
    # expect(find(:xpath, "//tr[contains(.,'#{monk.title}')]//input[@type='text']").value).to eq('2')
    # expect(find(:xpath, "//tr[contains(.,'#{h3h3.title}')]//input[@type='text']").value).to eq('3')
  end

  def add_video_to_queue(video)
    visit home_path
    find("a[href='/videos/#{video.id}']").click
    click_link "+ My Queue"
  end

  def expect_video_to_be_in_queue(video)
    expect(page).to have_content(video.title)
  end

  def expect_link_not_to_be_seen(link)
    expect(page).not_to have_content(link)
  end

  def set_video_position(video, position)
    within(:xpath, "//tr[contains(.,'#{video.title}')]") do
      fill_in 'queue_items[][position]', with: position
    end
  end

  def expect_video_position(video, position)
    expect(find(:xpath, "//tr[contains(.,'#{video.title}')]//input[@type='text']").value).to eq(position.to_s)
  end
end
