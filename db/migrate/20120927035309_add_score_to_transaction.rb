class AddScoreToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :score, :float
  end
end
