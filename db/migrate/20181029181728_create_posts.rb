class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
        t.string :title, null: false, default: "Title of Post"
        t.text :body, null: false, default: "Body of Post"
      t.timestamps
    end
  end
end
