require 'spec_helper'

describe ApiController do
  context "post a transactions" do
    let(:sample_transaction) {
      {
        transaction_id: "transaction_1",
        email: "email@client.com",
        ip: "1.2.3.4",
        name: "Client 1",
        purchaser_id: "purchaser_1",
        shipping_city: "San Francisco",
        shipping_country: "US",
        shipping_zip: "90494",
        shipping_state: "CA",
        transaction_datetime: "01-01-2012 10:25:40 +07:00",
        amount: "10.0",
        other_data: {
          oaddress: "N/A",
          ocity: "edina",
          ozip: "55439",
          ocountry: "us",
          xcity: "Minneapolis",
          language: "en-us",
          denomination: "USD",
          date2: "2011-11-25"
        },
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:11.0) Gecko/20100101 Firefox/11.0",
        http_accept_header: "text/html, */* gzip, deflate en-us,en;q=0.5",
        timezone: "-420",
        screen_info: "1920x1080x24"
      }
    }
    let(:user) { create(:merchant) }

    shared_examples_for "response 200" do
      describe "response to any kind of header" do
        before do
          request.accept = header_type
          post :transactions, sample_transaction.merge(api_key: user.api_key)
        end
        it "should response success" do
          response.should be_success
        end
        it "should store transaction field other_data of type HashWithIndifferentAccess" do
          transaction = assigns(:transaction)
          transaction.other_data.should be_kind_of(HashWithIndifferentAccess)
        end
      end
    end

    describe "with valid api_key" do
      let(:score_details) { { "description" => "Key" } }
      before do
        Transaction.any_instance.stub(:calculate_score!).and_return(60)
        FraudModel.any_instance.stub(:score_details).and_return(score_details)
      end

      context "json header" do
        it_should_behave_like "response 200" do
          let(:header_type) { "application/json" }
        end
      end

      context "html header" do
        it_should_behave_like "response 200" do
          let(:header_type) { "text/html" }
        end
      end

      it "should create a new transaction" do
        post :transactions, sample_transaction.merge(api_key: user.api_key)
        response.should be_success
        transaction = assigns(:transaction)
        transaction.transaction_id.should == "transaction_1"
        transaction.email.should == "email@client.com"
        transaction.ip.should == "1.2.3.4"
        transaction.name.should == "Client 1"
        transaction.purchaser_id.should == "purchaser_1"
        transaction.shipping_city.should == "San Francisco"
        transaction.shipping_country.should == "US"
        transaction.shipping_zip.should == "90494"
        transaction.shipping_state.should == "CA"
        transaction.unparsed_transaction_datetime.should == "01-01-2012 10:25:40 +07:00"
        transaction.transaction_datetime_offset.should == "+07:00"
        transaction.amount.should == 10.0
        transaction.other_data.should_not be_nil
        other_data = transaction.other_data
        other_data.class.should == ActiveSupport::HashWithIndifferentAccess
        other_data[:ocity].should == "edina"
        transaction.device_id.should == Digest::SHA1.hexdigest("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:11.0) Gecko/20100101 Firefox/11.0text/html, */* gzip, deflate en-us,en;q=0.5-4201920x1080x24")
      end

      it "should return a score and its breakdown (details)" do
        post :transactions, sample_transaction.merge(api_key: user.api_key)
        response.should be_success
        JSON(response.body).tap do |result|
          result["id"].should == assigns(:transaction).id
          result["score"].should == 60
          result["score_details"].should == score_details
        end
      end

      context "when missing transaction time zone offset" do
        it "should use default timezone from user setting" do
          user.reload.user_setting.update_attributes(time_zone: 'Mountain Time (US & Canada)')
          post :transactions, sample_transaction.merge(transaction_datetime: '01-01-2012 10:40:30', api_key: user.api_key)
          response.should be_success
          assigns(:transaction).transaction_datetime_offset.should == '-07:00'
        end
      end

      context "when missing transaction time" do
        it "should set transaction time to nil" do
          post :transactions, sample_transaction.merge(transaction_datetime: '01-01-2012 +05:00', api_key: user.api_key)
          response.should be_success
        end
      end
    end

    describe "with invalid api key" do
      it "should not create new transaction and return error" do
        lambda {
          post :transactions, sample_transaction.merge(api_key: 'Invalid key')
          response.status.should == 403
          response.body.should == {error: I18n.t('api.invalid_key')}.to_json
        }.should_not change(Transaction, :count)
      end
    end
  end
end
