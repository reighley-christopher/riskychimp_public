function nilify(val) {
if(val == "NULL") return "nil";
return "\"" val "\""
}

BEGIN {LC_ALL ="ASCII"; RS = "\n"; FS = "\t"; print "require('date')"} ;
{ 
  print "Transaction.create( :client_id => 1, ",
    ":transaction_id => " nilify($1) ",",
    ":amount => " $3 ",",
    ":transaction_datetime => Util::normalize_datetime(" nilify($4) ", \"Pacific Time (US & Canada)\"),",
    ":transaction_datetime_offset => \"-08:00\",",
    ":unparsed_transaction_datetime => " nilify($4) ",",
    ":email => " nilify($5) ",",
    ":name => " nilify($6) ",",
    ":ip => " nilify($7) ",",
    ":shipping_city => " nilify($9) ",",
    ":shipping_state => " nilify($10) ",",
    ":shipping_zip => " nilify($11) ",",
    ":shipping_country => " nilify($12) ",",
    ":purchaser_id => " nilify($13) ",",
    ":other_data => HashWithIndifferentAccess.new({ \"account_address\"=>" nilify($15) ",",
      "\"account_city\"=>" nilify($16) ",",
      "\"account_zip\"=>" nilify($17) ",",
      "\"account_country\"=>" nilify($18) ",",
      "\"account_city\"=>" nilify($19) ",",
      "\"language\"=>" nilify($20) ",",
      "\"denomination\"=>" nilify($8) ",",
      "\"first_seen\"=>" nilify($14) "}))";
}
