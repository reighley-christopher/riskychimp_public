require 'spec_helper'

describe FingerprintController do
  describe 'GET #download' do
    it "should send my swf file without corrupting it and with the correct content-type header" do
      file_size = File.size('app/assets/flash/fingerprint.swf')
      file_size.should > 0
      get :download
      response.should be_success
      response.body.length.should == file_size
      response.content_type.should == 'application/x-shockwave-flash'
    end

    it "should drop a cookie" do
      get :download
      response.cookies[FINGERPRINT_COOKIE_KEY].should_not be_nil
    end

    it "should create a record of the cookies it drops" do
      get :download
      response.cookies[FINGERPRINT_COOKIE_KEY].should == assigns(:browser).id.to_s
    end

    it "should use the cookie to look up @browser, if the cookie is present" do
      browser = FactoryGirl.create(:browser)
      request.cookies[FINGERPRINT_COOKIE_KEY] = browser.id
      get :download
      assigns(:browser).should == browser
    end
  end

  describe 'POST #phonehome' do
    it "should use the cookie to look up @browser, if the cookie is present" do
      browser = FactoryGirl.create(:browser)
      request.cookies[FINGERPRINT_COOKIE_KEY] = browser.id
      post :phonehome
      assigns(:browser).should == browser
    end

    it "should set @cookieless to true if the customer has cleared their cookies since we saw them last" do
      post :phonehome
      response.cookies[FINGERPRINT_COOKIE_KEY].should_not be_nil
      assigns(:cookieless).should == true
    end

    it "should parse the data as JSON, regardless of the 'content-type' header" do
      request.env["CONTENT_TYPE"] = "bad/content"
      request.env['RAW_POST_DATA'] = %Q{\{ "fonts" : "Times Fake Roman" \}}
      post :phonehome
      JSON.parse(response.body)['fingerprint'].should == Digest::SHA1.hexdigest("Rails Testing\n\n\nTimes Fake Roman")
    end

    it "should include 'accept' header information in the SHA1 fingerprint" do
      request.env["HTTP_ACCEPT"] = "1"
      request.env["HTTP_ACCEPT_ENCODING"] = "2"
      request.env["HTTP_ACCEPT_LANGUAGE"] = "3"
      request.env["HTTP_ACCEPT_CHARSET"] = "4"
      post :phonehome
      JSON.parse(response.body)['fingerprint'].should ==
          Digest::SHA1.hexdigest("Rails Testing1\n2\n3\n4")
    end
  end
end