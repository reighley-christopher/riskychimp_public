require 'spec_helper'

class FingerprintTestController < ApplicationController
  def test
    render '../../spec/javascripts/test', layout: false
  end

  def fingerprint
    respond_to do |format|
      format.js { render '../assets/fingerprint/fingerprint', layout: false }
    end
  end
end

describe "Fingerprint" do
  before :all do
    Capybara.default_driver = :selenium
    Riskybiz::Application.routes.draw do
      match '/test', controller: 'fingerprint_test', action: 'test'
      match '/fingerprint/fingerprint', controller: 'fingerprint_test', action: 'fingerprint'
      match 'fingerprint/phonehome', controller: 'fingerprint', action: 'phonehome'
    end
  end

  after :all do
    Riskybiz::Application.reload_routes!
  end

  describe "visit test page with embed script" do
    it "should send back data to server and receive fingerprint string" do
      visit "/test"
      wait_until {
        page.find("#fingerprint_status").text == "DONE"
      }
      page.find("#fingerprint_str").value.should_not be_blank
    end
  end
end