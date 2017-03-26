require 'spec_helper'

describe Category do
  # it "saves itself" do
  #   category = Category.new(name: "Horror")
  #   category.save
  #   expect(Category.first).to eq(category)
  # end
  #
  # it "has many videos" do
  #   category = Category.create(name: "Horror")
  #   video1 = Video.create(title: "A random title", description: "bleh", category: category)
  #   video2 = Video.create(title: "Second title", description: "lorem ipsum", category: category)
  #   expect(category.videos).to eq([video1, video2])
  # end

  it { should have_many(:videos) }

  describe '#recent_videos' do
    it 'returns the videos in the reverse chronological order by created at' do
      comedies = Category.create(name:'comedies')
      toradora = Video.create(title: 'Toradora', description: '1', category: comedies, created_at: 1.day.ago)
      sakurasou = Video.create(title: 'Sakurasou', description: '2', category: comedies)
      expect(comedies.recent_videos).to eq([sakurasou, toradora])
    end

    it 'returns all the videos if there are less than 6 videos' do
      comedies = Category.create(name:'comedies')
      toradora = Video.create(title: 'Toradora', description: '1', category: comedies, created_at: 1.day.ago)
      sakurasou = Video.create(title: 'Sakurasou', description: '2', category: comedies)
      expect(comedies.recent_videos.count).to eq(2)
    end

    it 'returns 6 videos if there are more than 6 videos' do
      comedies = Category.create(name: 'comedies')
      7.times do |idx|
        Video.create(title: "#{idx}", description: "#{idx}", category: comedies)
      end
      expect(comedies.recent_videos.count).to eq(6)
    end

    it 'returns the most recent 6 videos' do
      comedies = Category.create(name: 'comedies')
      6.times do |idx|
        Video.create(title: "#{idx}", description: "#{idx}", category: comedies)
      end
      konosuba = Video.create(title: "Kono Subarashii Sekai ni Shufuku wo!", description: "random", category: comedies, created_at: 1.day.ago)
      expect(comedies.recent_videos).not_to include(konosuba)
    end

    it 'returns an empty array if the category does not have any videos' do
      comedies = Category.create(name: 'comedies')
      expect(comedies.recent_videos.count).to eq(0)
    end
  end
end
