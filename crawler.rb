require 'rubygems'
require 'capybara'
require 'capybara-webkit'
require 'capybara-screenshot'
include Capybara::DSL

namespace :crawler do
  task :grab do
    Capybara.current_driver = :webkit
    Capybara.app_host = 'http://auto.inforico.com.ua'
    page.visit('/')
    puts '-------------------'
    puts page.text
    puts '-------------------'
    page.screenshot_and_open_image
  end
end
