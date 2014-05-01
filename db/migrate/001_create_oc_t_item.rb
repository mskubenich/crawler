class CreateOcTItem < ActiveRecord::Migration

  require 'active_record'
  require 'mysql2'

  def self.up
    create_table :oc_t_item do |t|
      t.integer :pk_i_id
      t.integer :fk_i_user_id
      t.integer :fk_i_category_id
      t.datetime :dt_pub_date
      t.datetime :dt_mod_date
      t.float :f_price
      t.integer :i_price
      t.string :fk_c_currency_code
      t.string :s_contact_name
      t.string :s_contact_email
      t.string :s_contact_phone
      t.string :s_ip
      t.boolean :b_premium
      t.boolean :b_enabled
      t.boolean :b_active
      t.boolean :b_spam
      t.string :s_secret
      t.boolean :b_show_email
      t.datetime :dt_expiration
      t.boolean :b_main_top
      t.boolean :b_cat_top
      t.boolean :b_select
      t.boolean :b_express
    end
  end

  def self.down
    drop_table :oc_t_item
  end
end