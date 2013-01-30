require 'csv'

transactions = Transaction.all.select{ |trans| rand < 0.10 }
log_amount = ExplanatoryVariable.lookup(:log_amount)
integer_datetime = ExplanatoryVariable.lookup(:integer_datetime)
addr_la = ExplanatoryVariable.lookup(:addr_la)
fp = CSV.open("./lib/data/training_data_0.csv", "w")

fp << ["category", "log_amount", "integer_datetime", "addr_la"]

transactions.each do |trans|
  fp << [rand < 0.50, log_amount.evaluate(trans), integer_datetime.evaluate(trans), addr_la.evaluate(trans)]
end

fp.close