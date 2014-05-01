require 'rubygems'
require 'capybara'
require 'capybara-webkit'
require 'capybara-screenshot'
require 'active_record'
require 'yaml'
require 'mysql2'

import 'app/models/item.rb'
import 'app/models/resource.rb'
import 'app/models/description.rb'
import 'app/models/location.rb'

dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'db/database.yml')))
ActiveRecord::Base.establish_connection dbconfig

namespace :crawler do
  task :grab do
    include Capybara::DSL

    dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'db/database.yml')))
    ActiveRecord::Base.establish_connection(dbconfig)


    Capybara.current_driver = :webkit
    Capybara.app_host = 'http://inforico.com.ua'
    page.visit('/')

    categories = Hash[page.all(:css, '.index-cat-title > span > a').map{|cat| [cat.text, cat[:href]]}]

    puts 'Get categories...'
    categories.each do |cat, cat_link|
      puts "#{ cat }:   #{cat_link}"
    end

    puts ""
    puts ""
    categories.each do |title, link|
      puts "Go to #{ title }..."
      puts "Get subcategories..."
      page.visit link

      sub_categories = Hash[page.all(:css, '.sf-subcats-a').map{|cat| [cat.text, cat[:href]]}]
      sub_categories.each do |cat, cat_link|
        puts "Go to subcategory #{ cat }:   #{cat_link}..."

        page.visit cat_link

        puts "Get operations..."
        operations = Hash[page.all(:css, '.sf-type').map{|cat| [cat.text, cat[:href]]}]

        operations.each do |operation, oper_link|
          puts "#{ operation }:   #{oper_link}"


          puts "Go to operation..."
          page.visit oper_link

          puts "Get items..."
          items = Hash[page.all(:css, '.item:not(.item-top) .alvi-title a').map{|cat| [cat.text, cat[:href]]}]

          items.each do |item, item_link|
            puts "#{ item }:   #{item_link}"

            page.visit item_link
            #page.screenshot_and_open_image

            item = Item.create
            location =  Location.create fk_i_item_id: item.id
            description = Description.create fk_i_item_id: item.id,
                                             s_title: page.find(:css, '.content .hl h1').text
            resource = Resource.create fk_i_item_id: item.id

            break #TODO remove this
          end

          break #TODO remove this
        end


        break #TODO remove this
      end

      puts ""
      puts ""

      break #TODO remove this
    end


  end
end
