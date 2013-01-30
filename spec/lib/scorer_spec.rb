require 'spec_helper'

describe Scorer do
  describe Scorer::OutlierOrder do
    let(:trans1) { FactoryGirl.create(:good_transaction, amount: 100,
                                      email: "jon.somebody@gmail.com",
                                      name:"Jon Somebody") }
    let(:trans2) { FactoryGirl.create(:good_transaction, amount: 99,
                                      email: "jack.nobody@gmail.com",
                                      name:"Jon Somebody") }
    let(:trans3) { FactoryGirl.create(:good_transaction, amount: 101,
                                      email: "james.anyone@gmail.com",
                                      name:"Jon Somebody") }
    let(:trans4) { FactoryGirl.create(:good_transaction, amount: 1000,
                                      email: "jon.somebody@gmail.com",
                                      name:"Jon Somebody") }

    let(:sample) { TrainingSample.new([trans1, trans2, trans3, trans4], [:amount, :email_match]) }

    it "should sort these according to their probabilities in the sample" do
      terms = { amount: { order: Util::Order::number_increasing, weight: 1 },
                email_match: { order: Util::Order::tf_order, weight: 1 } }
      #TODO: should the orders be passed as strings?

      scorer = Scorer::OutlierOrder.new(sample, { terms: terms })

      v1 = scorer.apply(amount: 100, email_match: true)
      v2 = scorer.apply(amount: 99, email_match: false)
      v3 = scorer.apply(amount: 101, email_match: false)
      v4 = scorer.apply(amount: 1000, email_match: true)

      v1.should be_within(0.001).of (1 - (0.75 ** 0.5))
      v2.should be_within(0.001).of (1 - (0.5 ** 0.5))
      v3.should be_within(0.001).of (1 - (0.25 ** 0.5))
      v4.should be_within(0.001).of (1 - (0.25 ** 0.5))
    end

    it "should conform to the default behavior if the weights are all equal" do
      terms = { amount: { order: Util::Order::number_increasing, weight: 2 },
                email_match: { order: Util::Order::tf_order, weight: 2 } }
      scorer = Scorer::OutlierOrder.new(sample, { terms: terms })

      v1 = scorer.apply(amount: 100, email_match: true)
      v2 = scorer.apply(amount: 99, email_match: false)
      v3 = scorer.apply(amount: 101, email_match: false)
      v4 = scorer.apply(amount: 1000, email_match: true)

      v1.should be_within(0.001).of 1 - (0.75 ** 0.5)
      v2.should be_within(0.001).of 1 - (0.5 ** 0.5)
      v3.should be_within(0.001).of (1 - (0.25 ** 0.5))
      v4.should be_within(0.001).of (1 - (0.25 ** 0.5))
    end

    it "should respond to variations in the relative weights" do
      terms = { amount: { order: Util::Order::number_increasing, weight: 3 },
                email_match: { order: Util::Order::tf_order, weight: 1 } }
      scorer = Scorer::OutlierOrder.new(sample, { terms: terms })

      v1 = scorer.apply(amount: 100, email_match: true)
      v2 = scorer.apply(amount: 99, email_match: false)
      v3 = scorer.apply(amount: 101, email_match: false)
      v4 = scorer.apply(amount: 1000, email_match: true)

      v1.should be_within(0.001).of 1 - (0.75 ** 0.75)
      v2.should be_within(0.001).of 1 - (0.5 ** 0.25)
      v3.should be_within(0.001).of 1 - (0.5 ** 1)
      v4.should be_within(0.001).of 1 - (0.25 ** 0.75)
      v2.should < v1
      v1.should < v3
      v3.should < v4
    end

    it "should provide lists of numbers about how the score was computed" do
      terms = { amount: { order: Util::Order::number_increasing, weight: 3 },
                email_match: { order: Util::Order::tf_order, weight: 1 } }
      scorer = Scorer::OutlierOrder.new(sample, { terms: terms})

      v1 = scorer.apply(amount: 100, email_match: true)
      v2 = scorer.apply(amount: 99, email_match: false)
      v3 = scorer.apply(amount: 101, email_match: false)
      v4 = scorer.apply(amount: 1000, email_match: true)

      v1.proportion_of_score.values.sum.should be_within(0.01).of(1)
      v2.proportion_of_score.values.sum.should be_within(0.01).of(1)
      v3.proportion_of_score.values.sum.should be_within(0.01).of(1)
      v4.proportion_of_score.values.sum.should be_within(0.01).of(1)

      v3.proportion_of_score[:amount].should be_within(0.01).of(Math.log((1 - 0.5) ** 0.75) / Math.log(1.0 - v3))
      v3.proportion_of_score[:email_match].should be_within(0.01).of(Math.log((1 - 0.5) ** 0.25) / Math.log(1.0 - v3))

      v1.quantile_of_feature[:amount].should be_within(0.01).of(0.25)
      v1.quantile_of_feature[:email_match].should be_within(0.01).of(0)

      v1.value_of_feature[:amount].should == 100
      v1.value_of_feature[:email_match].should == true
    end

    it "should not produce invalid values in response to out of range inputs" do
      terms = { amount: { order: Util::Order::number_increasing, weight: 3 },
                email_match: { order: Util::Order::tf_order, weight: 1 } }
      scorer = Scorer::OutlierOrder.new(sample, { terms: terms })

      val = scorer.apply(amount: 1000000, email_match: true)
      val.proportion_of_score[:amount].should_not be_nan

      val2 = scorer.apply(amount: 1, email_match: true)
      val2.should == 0
      val2.proportion_of_score[:amount].should_not be_nan
    end

    describe "parse_model_params" do
      it "should parse a JSON model params string" do
        params_string =
            {
                terms: {
                    amount: { order: "Util::Order::number_increasing", weight: 1 },
                    domain_type: { order: "Util::Order::array_to_order(#{[:protected, :service, :free, :unknown, nil, :disposable].to_json})",
                                   weight: 2 },
                }
            }.to_json

        parsed_params = Scorer::OutlierOrder.parse_model_params(params_string)
        terms = parsed_params[:terms]

        amount = terms[:amount]
        amount_order = Util::Order::string_to_known_order("Util::Order::number_increasing")
        amount_order.with_column(DataColumn.new([])).call(5, 6).should == -1
        amount[:weight].should == 1

        domain_type = terms[:domain_type]
        domain_type_order = Util::Order::string_to_known_order(domain_type[:order])

        domain_type_order.call(:protected, :unknown).should == -1
        domain_type_order.call(nil, :service).should == 1
        domain_type[:weight].should == 2
      end

      it "should undo to_json" do
        model_params_string =
            {
                terms: {
                    amount: { order: "Util::Order::number_increasing", weight: 1 },
                    domain_type: { order: "Util::Order::array_to_order(#{[:protected, :service, :free, :unknown, nil, :disposable].to_json})",
                                   weight: 2 },
                }
            }.to_json
        Scorer::OutlierOrder.parse_model_params(model_params_string).to_json.should == model_params_string
      end

      it "should work with the default model parameters" do
        model_params_string = Scorer::OutlierOrder.default_model_params.to_json
        Scorer::OutlierOrder.parse_model_params(model_params_string).to_json.should == model_params_string
      end
    end

    describe "apply_params" do
      it "should do the thing it does, sometimes" do
        the_hash = { amount: 99, domain_type: 88 }
        the_string =
          {
                terms: {
                    amount: { order: "Util::Order::number_increasing", weight: 1 },
                    domain_type: { order: "Util::Order::array_to_order([\"protected\", \"service\", \"free\", \"unknown\", null, \"disposable\"]})",
                                   weight: 2 },
                }
            }.to_json
        the_expected =
          {
                terms: {
                    amount: { order: "Util::Order::number_increasing", weight: 99.0 },
                    domain_type: { order: "Util::Order::array_to_order([\"protected\", \"service\", \"free\", \"unknown\", null, \"disposable\"]})",
                                   weight: 88.0 },
                }
            }.to_json
        Scorer::OutlierOrder.apply_params(the_string, the_hash).should == the_expected
      end

      it "should still do the thing it does, the rest of the time" do
        the_hash = { amount: 99, domain_type: 88 }
        Scorer::OutlierOrder.apply_params(nil, the_hash).should  include( "\"weight\":99" )
      end
    end

    describe "column_names" do
      it "should return the column names needed to generate a sample" do
        terms = { amount: { order: Util::Order::number_increasing, weight: 3 },
                  blah_nonexistant_ev: { order: Util::Order::tf_order, weight: 1 } }

        names = Scorer::OutlierOrder.column_names({ terms: terms})
        names.should include :amount
        names.should include :blah_nonexistant_ev
      end

      it "should return column names from default if no argument is given" do
        names = Scorer::OutlierOrder.column_names
        names.should include :amount
      end
    end
  end
end

