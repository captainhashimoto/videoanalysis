class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :image_url
      t.string :user_name
      t.string :athlete
      t.string :event
      t.string :video_id
      t.text :commnet
      t.integer :user_id
    end
  end
end
