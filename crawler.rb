require 'rubygems'
require 'capybara'
require 'capybara-webkit'
require 'capybara-screenshot'
include Capybara::DSL

namespace :crawler do
  task :grab do
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
          end

          break #TODO remove this
        end


        break #TODO remove this
      end

      puts ""
      puts ""

      break #TODO remove this
      #page.screenshot_and_open_image
    end


  end
end
