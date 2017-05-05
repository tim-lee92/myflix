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

  describe '.rating' do
    it 'should return an average rating score' do
      video = Fabricate(:video)
      review1 = Fabricate(:review, rating: 5, video_id: video.id)
      review1 = Fabricate(:review, rating: 2, video_id: video.id)
      review1 = Fabricate(:review, rating: 3, video_id: video.id)
      review1 = Fabricate(:review, rating: 3, video_id: video.id)
      expect(video.rating).to eq(3.25)
    end
  end

  describe ".search", :elasticsearch do
    let(:refresh_index) do
      Video.import
      Video.__elasticsearch__.refresh_index!
    end

    context "with title" do
      it "returns no results when there's no match" do
        Fabricate(:video, title: "Futurama")
        refresh_index

        expect(Video.search("whatever").records.to_a).to eq []
      end

      it "returns an empty array when there's no search term" do
        futurama = Fabricate(:video)
        south_park = Fabricate(:video)
        refresh_index

        expect(Video.search("").records.to_a).to eq []
      end

      it "returns an array of 1 video for title case insensitve match" do
        futurama = Fabricate(:video, title: "Futurama")
        south_park = Fabricate(:video, title: "South Park")
        refresh_index

        expect(Video.search("futurama").records.to_a).to eq [futurama]
      end

      it "returns an array of many videos for title match" do
        star_trek = Fabricate(:video, title: "Star Trek")
        star_wars = Fabricate(:video, title: "Star Wars")
        refresh_index

        expect(Video.search("star").records.to_a).to match_array [star_trek, star_wars]
      end
    end

    context "with title and description" do
      it "returns an array of many videos based for title and description match" do
        star_wars = Fabricate(:video, title: "Star Wars")
        about_sun = Fabricate(:video, description: "sun is a star")
        refresh_index

        expect(Video.search("star").records.to_a).to match_array [star_wars, about_sun]
      end
    end

    context "multiple words must match" do
      it "returns an array of videos where 2 words match title" do
        star_wars_1 = Fabricate(:video, title: "Star Wars: Episode 1")
        star_wars_2 = Fabricate(:video, title: "Star Wars: Episode 2")
        bride_wars = Fabricate(:video, title: "Bride Wars")
        star_trek = Fabricate(:video, title: "Star Trek")
        refresh_index

        expect(Video.search("Star Wars").records.to_a).to match_array [star_wars_1, star_wars_2]
      end
    end

    context "with title, description and reviews" do
      it 'returns an an empty array for no match with reviews option' do
        star_wars = Fabricate(:video, title: "Star Wars")
        batman    = Fabricate(:video, title: "Batman")
        batman_review = Fabricate(:review, video: batman, content: "such a star movie!")
        refresh_index

        expect(Video.search("no_match", reviews: true).records.to_a).to eq([])
      end

      it 'returns an array of many videos with relevance title > description > review' do
        star_wars = Fabricate(:video, title: "Star Wars")
        about_sun = Fabricate(:video, description: "the sun is a star!")
        batman    = Fabricate(:video, title: "Batman")
        batman_review = Fabricate(:review, video: batman, content: "such a star movie!")
        refresh_index

        expect(Video.search("star", reviews: true).records.to_a).to eq([star_wars, about_sun, batman])
      end
    end

    context "filter with average ratings" do
      let(:star_wars_1) { Fabricate(:video, title: "Star Wars 1") }
      let(:star_wars_2) { Fabricate(:video, title: "Star Wars 2") }
      let(:star_wars_3) { Fabricate(:video, title: "Star Wars 3") }

      before do
        Fabricate(:review, rating: "2", video: star_wars_1)
        Fabricate(:review, rating: "4", video: star_wars_1)
        Fabricate(:review, rating: "4", video: star_wars_2)
        Fabricate(:review, rating: "2", video: star_wars_3)
        refresh_index
      end

      context "with only rating_from" do
        it "returns an empty array when there are no matches" do
          expect(Video.search("Star Wars", rating_from: "4.1").records.to_a).to eq []
        end

        it "returns an array of one video when there is one match" do
          expect(Video.search("Star Wars", rating_from: "4.0").records.to_a).to eq [star_wars_2]
        end

        it "returns an array of many videos when there are multiple matches" do
          expect(Video.search("Star Wars", rating_from: "3.0").records.to_a).to match_array [star_wars_2, star_wars_1]
        end
      end

      context "with only rating_to" do
        it "returns an empty array when there are no matches" do
          expect(Video.search("Star Wars", rating_to: "1.5").records.to_a).to eq []
        end

        it "returns an array of one video when there is one match" do
          expect(Video.search("Star Wars", rating_to: "2.5").records.to_a).to eq [star_wars_3]
        end

        it "returns an array of many videos when there are multiple matches" do
          expect(Video.search("Star Wars", rating_to: "3.4").records.to_a).to match_array [star_wars_1, star_wars_3]
        end
      end

      context "with both rating_from and rating_to" do
        it "returns an empty array when there are no matches" do
          expect(Video.search("Star Wars", rating_from: "3.4", rating_to: "3.9").records.to_a).to eq []
        end

        it "returns an array of one video when there is one match" do
          expect(Video.search("Star Wars", rating_from: "1.8", rating_to: "2.2").records.to_a).to eq [star_wars_3]
        end

        it "returns an array of many videos when there are multiple matches" do
          expect(Video.search("Star Wars", rating_from: "2.9", rating_to: "4.1").records.to_a).to match_array [star_wars_1, star_wars_2]
        end
      end
    end
  end
end
