require 'explanatory_variable'

explanatory_variable :cards_by_ip do
  type :numeric
  input Transaction
  description "number of distinct credit cards used from this transaction's ip"
  calculate do |trans|
    transactions = Transaction.where('ip = :ip and transaction_datetime <= :transaction_datetime',
                                     { ip: trans.ip,
                                       transaction_datetime: trans.transaction_datetime }  )
    transactions.map do |transaction|
      transaction.other_data[:cc_digest]
    end.uniq.count
  end
end

explanatory_variable :cards_by_print do
  type :numeric
  input Transaction
  description "number of distinct credit cards used from a browser with this transaction's fingerprint"
  calculate do |trans|
    transactions = Transaction.where('device_id = :device_id and transaction_datetime <= :transaction_datetime',
                                     { device_id: trans.device_id,
                                       transaction_datetime: trans.transaction_datetime }  )
    transactions.map do |transaction|
      transaction.other_data[:cc_digest]
    end.uniq.count
  end
end

explanatory_variable :frequency_of_ip do
  type :numeric
  input Transaction
  description "number of transaction's from this ip"
  calculate do |trans|
    Transaction.where('ip = :ip and transaction_datetime <= :transaction_datetime',
                      { ip: trans.ip,
                      transaction_datetime: trans.transaction_datetime }  ).count
  end
end

explanatory_variable :frequency_of_print do
  type :numeric
  input Transaction
  description "number transactions from browser with this transaction's fingerprint"
  calculate do |trans|
    Transaction.where('device_id = :device_id and transaction_datetime <= :transaction_datetime',
                      { device_id: trans.device_id,
                      transaction_datetime: trans.transaction_datetime }  ).count
  end
end

explanatory_variable :customer_loyalty do
  type :numeric
  input Transaction
  description "number of transactions by this transaction's purchaser id"
  calculate do |trans|
    Transaction.where('client_id = :client_id and purchaser_id = :purchaser_id ' +
                          'and transaction_datetime <= :transaction_datetime',
                      { client_id: trans.client_id,
                        purchaser_id: trans.purchaser_id,
                        transaction_datetime: trans.transaction_datetime }  ).count
  end
end

explanatory_variable :frequency_of_ip_today do
  type :numeric
  input Transaction
  description "number of transaction's from this ip in the previous 24 hours"
  calculate do |trans|
    next nil if trans.transaction_datetime.nil?
    Transaction.where('ip = :ip and transaction_datetime <= :transaction_datetime_end and transaction_datetime >= :transaction_datetime_start',
                      { ip: trans.ip,
                        transaction_datetime_start: trans.transaction_datetime - 1.day,
                        transaction_datetime_end: trans.transaction_datetime}  ).count
  end
end

explanatory_variable :frequency_of_print_today do
  type :numeric
  input Transaction
  description "number transactions from browser with this transaction's fingerprint in the previous 24 hours"
  calculate do |trans|
    next nil if trans.transaction_datetime.nil?
    Transaction.where('device_id = :device_id and transaction_datetime <= :transaction_datetime_end and transaction_datetime >= :transaction_datetime_start',
                      { device_id: trans.device_id,
                        transaction_datetime_start: trans.transaction_datetime - 1.day,
                        transaction_datetime_end: trans.transaction_datetime}  ).count
  end
end