require('explanatory_variable')

explanatory_variable :fraudy do
  asset(:fraudlies) { ["72877761", "67625895", "76428885", "64569747", "66975765", "79941071", "66137529", "66932469", "63575711", "63524303", "69221321", "78808109", "76017053", "77859979", "75703383", "78765787"] }
  calculate do |trans|
    fraudlies.include? trans.transaction_id
  end
end

class FeaturesDigest
  require('csv')

  def self.stuff()
    feat = FeaturesDigest.new()
    ExplanatoryVariable.lookup("name") #TODO oops, bug.  calling catalog should also seed the list
    feat.open("lib/other/features_digest.csv")
    feat.write_header
    self.load_public_ips
    #sample = TrainingSample.new(Transaction.all, ExplanatoryVariable.catalog.keys -
    #    [:fraud_score, :bucketted_integer_datetime, :bucketted_amount, :normalized_addr_la, :normalized_datetime,
    #     :normalized_log_amount, :svm, :id3, :bucketted_addr_la])
    sample = TrainingSample.new('lib/data/big_sample.csv')
    Transaction.find_each do |f|
      feat.write(f, sample)
    end
    feat.close
  end

  def initialize
    @evs = ExplanatoryVariable.catalog.values
  end

  def open(name)
    #@zips = Util::ZipDatabase.new
    @fp = CSV.open(name, "w+")
  end

  def close
    @fp.close
  end

  def self.load_public_ips
    Util::IP.seed_public_computers(Transaction.find_public_ips)
  end

  def write_header
    row = []
    row << "client_id"
    row << "transaction_id"
    @evs.each do |ev|
      row << ev.name
      p ev.name, ev.description ####
    end
    @fp << row
  end

  def write(trans, sample)
    row = []
    row << trans.client_id
    row << trans.transaction_id
    @evs.each do |ev|
      row << ev.evaluate(trans, sample: sample)
      p ev.name, ev.last_error, ev.last_error.backtrace if ev.last_error
    end
    @fp << row
  end
end

FeaturesDigest.stuff