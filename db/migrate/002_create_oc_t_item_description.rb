class CreateOcTItemDescription < ActiveRecord::Migration

  require 'active_record'
  require 'mysql2'

  def self.up
    create_table :oc_t_item_description do |t|
      t.integer :fk_i_item_id
      t.string :fk_c_locale_code
      t.string :s_title
      t.text :s_description
    end
  end

  def self.down
    drop_table :oc_t_item_description
  end
end