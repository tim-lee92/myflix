require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:full_name) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:queue_items).order('position') }
  it { should have_many(:reviews).order('created_at DESC') }

  it_behaves_like 'tokenable' do
    let(:object) { Fabricate(:user) }
  end

  describe '#queued_video?' do
    it 'returns true when the user queued the video' do
      user = Fabricate(:user)
      video = Fabricate(:video)
      Fabricate(:queue_item, user: user, video: video)
      expect(user.queued_video?(video)).to be_truthy
    end

    it 'returns false when the user did not queue the video' do
      user = Fabricate(:user)
      video = Fabricate(:video)
      expect(user.queued_video?(video)).to be_falsey
    end
  end

  describe '#follows?' do
    it 'returns true if the user has a following relationship with another user' do
      jacky = Fabricate(:user)
      richard = Fabricate(:user)
      Fabricate(:relationship, leader: richard, follower: jacky)
      expect(jacky.follows?(richard)).to be_truthy
    end

    it 'returns false if the user has a following relationship with another user' do
      jacky = Fabricate(:user)
      richard = Fabricate(:user)
      expect(jacky.follows?(richard)).to be_falsey
    end
  end

  describe '#follow' do
    it 'follows another user' do
      lily = Fabricate(:user)
      jacky = Fabricate(:user)
      lily.follow(jacky)
      expect(lily.follows?(jacky)).to be_truthy
    end

    it 'does not follow one self' do
      lily = Fabricate(:user)
      lily.follow(lily)
      expect(lily.follows?(lily)).to be_falsey
    end
  end
end
