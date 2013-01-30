class CreateLocations < ActiveRecord::Migration
  def up
    create_table :locations do |t|
      t.string :zip
      t.string :city
      t.string :state
      t.float :lat
      t.float :long
      t.string :country, :limit => 2
    end

    add_index :locations, [:zip, :country]
    add_index :locations, :zip
  end

  def down
    drop_table :locations
  end
end
