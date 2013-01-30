require 'spec_helper'

describe Article do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:url) }
  end

  describe "#build_from_params" do
    it "should set attributes to new record" do
      og_mock = double(title: 'My Title', description: 'My Description', images: ['image1.jpg', 'image2.jpg'])
      OpenGraph.should_receive(:new).with('http://test.host').and_return(og_mock)
      article = Article.build_from_params({:url => 'http://test.host'})
      article.title.should == "My Title"
      article.description.should == "My Description"
      article.image_url.should == "image1.jpg"
      article.images.should == ['image1.jpg', 'image2.jpg']
    end
  end
end
