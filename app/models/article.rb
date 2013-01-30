class Article < ActiveRecord::Base
  @@per_page = 10
  cattr_reader :per_page
  attr_accessible :description, :image_url, :title, :url, :comment
  attr_accessor :images

  validates_presence_of :url, :title

  def images_for_select
    @images ||= [image_url]
    @images.each_with_index.collect{ |url, index| ["Thumbnail #{index + 1}", url] }
  end

  def self.build_from_params(opts)
    article = new(opts)
    og = OpenGraph.new(article.url)
    article.title = og.title
    article.description = og.description
    article.images = og.images
    article.image_url = article.images.first
    article
  end
end
