require 'spec_helper'

describe Video do
  # it 'saves itself' do
  #   video = Video.new(title: 'Hello World', description: 'a great video!')
  #   video.save
  #   expect(Video.first).to eq(video)
  # end

  it { should belong_to(:category) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:reviews).order('created_at DESC')}

  # it 'belongs to category' do
  #   thriller = Category.create(name: 'Thriller')
  #   walking_dead = Video.create(title: 'Walking Dead', description: 'blah', category: thriller)
  #   expect(walking_dead.category).to eq(thriller)
  # end
  #
  # it 'does not save a video without a title' do
  #   video = Video.create(description: 'blurrrrr')
  #   expect(Video.count).to eq(0)
  # end
  #
  # it 'does not save a video without a description' do
  #   video = Video.create(title: 'blurrrrr')
  #   expect(Video.count).to eq(0)
  # end

  describe 'search_by_title' do
    it 'returns an empty array if there is no match' do
      futurama = Video.create(title: 'Futurama', description: 'lorem')
      toradora = Video.create(title: 'Toradora', description: 'ipsum')
      expect(Video.search_by_title('hello')).to eq([])
    end

    it 'returns an array of one video for an exact match' do
      futurama = Video.create(title: 'Futurama', description: 'lorem')
      toradora = Video.create(title: 'Toradora', description: 'ipsum')

      expect(Video.search_by_title('Toradora')).to eq([toradora])
    end

    it 'returns an array of one video for a partial match' do
      futurama = Video.create(title: 'Futurama', description: 'lorem')
      toradora = Video.create(title: 'Toradora', description: 'ipsum')
      expect(Video.search_by_title('dora')).to eq([toradora])
    end

    it 'returns an array of all matches ordered by created_at' do
      futurama = Video.create(title: 'Futurama', description: 'lorem')
      toradora = Video.create(title: 'Toradora', description: 'ipsum', created_at: 1.day.ago)
      expect(Video.search_by_title('a')).to eq([futurama, toradora])
    end

    it 'returns an empty array if there is an empty search string' do
      futurama = Video.create(title: 'Futurama', description: 'lorem')
      toradora = Video.create(title: 'Toradora', description: 'ipsum')
      expect(Video.search_by_title('')).to eq([])
    end

    it 'returns an array of one video for a match regardless of letter case' do
      futurama = Video.create(title: 'Futurama', description: 'lorem')
      toradora = Video.create(title: 'Toradora', description: 'ipsum', created_at: 1.day.ago)
      expect(Video.search_by_title('tora')).to eq([toradora])
      expect(Video.search_by_title('Dora')).to eq([toradora])
      expect(Video.search_by_title('rAdO')).to eq([toradora])
    end

  end
end
