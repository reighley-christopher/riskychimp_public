class CreateBrowsers < ActiveRecord::Migration
  def change
    create_table :browsers do |t|
      t.text :fonts
      t.string :flash_version

      t.timestamps
    end
  end
end
