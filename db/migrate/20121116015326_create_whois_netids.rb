class CreateWhoisNetids < ActiveRecord::Migration
  def change
    create_table :whois_netids do |t|
      t.string :netid
      t.text :whois_arin
      t.text :whois_radb

      t.timestamps
    end

    add_index :whois_netids, :netid, :unique => true
  end
end
