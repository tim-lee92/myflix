class VideosController < ActionController::Base

  layout 'application'

  def home
    @videos = Video.all
    @categories = Category.all

    render 'videos/index'
  end

  def details
    title = params[:title].split('_')
    title.map do |word|
      word.capitalize!
    end
    title = title.join(' ')
    @video = Video.find_by({ title: title })

    render 'videos/details'
  end

  def search
    @results = Video.search_by_title(params[:search_term])
  end
end
