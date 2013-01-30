class AddCompanyNameAndCompanyWebsiteToUser < ActiveRecord::Migration
  def change
    add_column :users, :company_name, :string
    add_column :users, :company_website, :string
  end
end
