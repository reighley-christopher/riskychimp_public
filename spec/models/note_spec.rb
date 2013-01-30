require 'spec_helper'

describe Note do
  describe "associations" do
    it { should belong_to(:transaction) }
  end

  describe "validations" do
    it { should validate_presence_of(:transaction) }
    it { should validate_presence_of(:content) }
  end
end
