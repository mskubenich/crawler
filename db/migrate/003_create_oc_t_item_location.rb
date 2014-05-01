class CreateOcTItemLocation < ActiveRecord::Migration

  require 'active_record'
  require 'mysql2'

  def self.up
    create_table :oc_t_item_location do |t|
      t.integer :fk_i_item_id
      t.string :fk_c_country_code
      t.string :s_country
      t.string :s_address
      t.string :s_zip
      t.integer :fk_i_region_id
      t.string :s_region
      t.integer :fk_i_city_id
      t.string :s_city
      t.integer :fk_i_city_area_id
      t.string :s_city_area
      t.float :d_coord_lat
      t.float :d_coord_long
      t.text :s_phone
    end
  end

  def self.down
    drop_table :oc_t_item_location
  end
end