require 'spec_helper'

describe UserSetting do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_numericality_of(:amount_threshold)}
    it { should ensure_inclusion_of(:time_zone).in_array(ActiveSupport::TimeZone.zones_map.keys)}
  end

  describe "fraud_model" do
    it "should certainly exist" do
      merchant = FactoryGirl.create(:merchant)
      merchant.fraud_model.should_not be_nil
    end
  end

  describe "the things the controller must see" do
    describe "adjustable_model_parameters" do
      it "should know which parameters are adjustable" do
        merchant = FactoryGirl.create(:merchant)
        model_params = merchant.user_setting.adjustable_model_parameters
        model_params.should include(:amount)
        model_params[:amount].should == 1
      end

      it "should not mutate the model_parameters if I modify the hash" do
        merchant = FactoryGirl.create(:merchant)
        model_params = merchant.user_setting.adjustable_model_parameters
        model_params[:amount] = 0.49
        merchant.user_setting.adjustable_model_parameters.should_not == model_params
      end
    end

    describe "set_model_parameters" do
      it "should update the parameter values and force the model to be refreshed" do
        merchant = FactoryGirl.create(:merchant)
        old_model = merchant.fraud_model()
        model_params = merchant.user_setting.adjustable_model_parameters
        model_params[:amount] = 0.49
        merchant.user_setting.set_model_parameters(model_params)
        merchant.save!
        merchant.user_setting.adjustable_model_parameters[:amount].should == 0.49
        merchant.fraud_model.should_not == old_model
      end
    end
  end
end
