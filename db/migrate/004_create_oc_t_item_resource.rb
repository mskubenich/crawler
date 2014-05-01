class CreateOcTItemResource < ActiveRecord::Migration

  require 'active_record'
  require 'mysql2'

  def self.up
    create_table :oc_t_item_resource do |t|
      t.integer :pk_i_id
      t.integer :fk_i_item_id
      t.string :s_name
      t.string :s_extension
      t.string :s_content_type
      t.string :s_path
    end
  end

  def self.down
    drop_table :oc_t_item_resource
  end
end