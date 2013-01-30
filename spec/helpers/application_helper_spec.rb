require 'spec_helper'

describe ApplicationHelper do
  describe "logo_tag" do
    context "with nil url" do
      it "should return the no-logo image" do
        logo_tag(nil).should == "<img alt=\"No-logo\" height=\"100\" src=\"/images/no-logo.png\" width=\"100\" />"
      end
    end
    context "with valid url" do
      it "should return the right image" do
        logo_tag("https://riskybiz.s3.amazonaws.com/production/uploads/user/logo/1/logo.png").should == "<img alt=\"Logo\" height=\"100\" src=\"https://riskybiz.s3.amazonaws.com/production/uploads/user/logo/1/logo.png\" width=\"100\" />"
      end
    end
  end
end
