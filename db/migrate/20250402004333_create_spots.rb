class CreateSpots < ActiveRecord::Migration[7.2]
  def change
    create_table :spots do |t|
      t.string :name
      t.string :address
      t.integer :rating
      t.string :image_url
      t.text :description

      t.timestamps
    end
  end
end
