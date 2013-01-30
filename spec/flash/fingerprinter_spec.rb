require 'spec_helper'

class FlashTestController < ApplicationController
  def test
   render '../../spec/flash/test', layout: false
  end
end

describe "Flash Fingerprinter" do
  before :all do
    Capybara.default_driver = :selenium
    Riskybiz::Application.routes.draw do
      match '/test/', controller: 'flash_test', action: :test
      match '/fingerprint/fingerprint.swf', controller: 'fingerprint', action: :download
      match 'fingerprint/phonehome', controller: 'fingerprint', action: :phonehome
    end
  end

  after :all do
    Riskybiz::Application.reload_routes!
  end

  it "should at least load" do
    visit '/test/'
    page.should have_content("SEEN")
    page.find_by_id('sanity_check').should have_content("SANE")
    page.find_by_id('response_check').should have_content("RESPONSIVE")
  end

  it "should have font, version, offset, and plugin information" do
    visit '/test/'
    page.find_by_id('font_check').should have_content('Bold')
    page.find_by_id('font_check').should have_content('Italic')
    page.find_by_id('font_check').should have_content('Sans')

    ["WIN", "MAC", "LNX", "AND"].any? {|str| page.find_by_id('capabilities_check').text.include?(str) }.should be_true

    page.find_by_id('utc_offset_check').text.length.should be >= 3
    page.find_by_id('utc_offset_check').text.length.should be <= 9

    page.find_by_id('plugins_check').should have_content('x-shockwave-flash')
  end

  it "should report back to the server" do
    visit '/test/'
    time = Time.now()
    while(Time.now - time < 5)
      break unless page.find_by_id('communications_check').text.blank?
    end
    page.find_by_id('communications_check').text.should_not be_blank
  end

  it "should gather no elements that are not used by the Thumbprint class" do
    visit '/test/'
    time = Time.now()
    while(Time.now - time < 5)
      break unless page.find_by_id('json').text.blank?
    end
    text = page.find_by_id('json').text
    json = JSON.parse(text)
    fingerprint = Thumbprint.generate(json)
    json.keys.each do |key|
      changed = json.dup
      changed[key] = ""
      changed[key] = "not blank" if json[key] == ""
      Thumbprint.generate(changed).should_not == fingerprint
    end
  end
end
