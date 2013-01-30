class AddCommentToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :comment, :text
  end
end
