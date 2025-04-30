class AddPlaceIdToSpots < ActiveRecord::Migration[7.2]
  def change
    add_column :spots, :place_id, :string
  end
end
