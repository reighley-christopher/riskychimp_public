require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      redirect_to_with_js '/'
    end
  end

  describe "redirect_to_with_js" do
    context "with html format" do
      it "should redirect to given path as normal" do
        get :index
        response.should redirect_to('/')
      end
    end
    context "with js format" do
      it "should render js contain to redirect page to given path" do
        get :index, format: :js
        response.body.should == "window.location.pathname='/'"
      end
    end
  end
end