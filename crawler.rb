require 'rubygems'
require 'capybara'
require 'capybara-webkit'
require 'capybara-screenshot'
require 'active_record'
require 'yaml'
require 'mysql2'
require 'open-uri'
require 'RMagick'

import 'app/models/item.rb'
import 'app/models/resource.rb'
import 'app/models/description.rb'
import 'app/models/location.rb'

dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'db/database.yml')))
ActiveRecord::Base.establish_connection dbconfig

namespace :crawler do
  task :grab do

    @app_config = YAML::load(File.open(File.join(File.dirname(__FILE__), 'settings.yml')))


    include Capybara::DSL

    dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'db/database.yml')))
    ActiveRecord::Base.establish_connection(dbconfig)


    Capybara.current_driver = :webkit
    Capybara.app_host = 'http://inforico.com.ua'
    page.visit('/')

    categories = Hash[page.all(:css, '.index-cat-title > span > a').map{|cat| [cat.text, cat[:href]]}]

    #puts 'Get categories...'
    categories.each do |cat, cat_link|
      #puts "#{ cat }:   #{cat_link}"
    end

    #puts ""
    #puts ""
    categories.each do |title, link|
      #puts "Go to #{ title }..."
      #puts "Get subcategories..."
      page.visit link

      sub_categories = Hash[page.all(:css, '.sf-subcats-a').map{|cat| [cat.text, cat[:href]]}]
      sub_categories.each do |cat, cat_link|
        #puts "Go to subcategory #{ cat }:   #{cat_link}..."
        
        category_name = title
        subcategory_name = cat


        page.visit cat_link

        #puts "Get operations..."
        operations = Hash[page.all(:css, '.sf-type').map{|cat| [cat.text, cat[:href]]}]

        operations.each do |operation, oper_link|
          #puts "#{ operation }:   #{oper_link}"
            
          operation_name = operation

          #puts "Go to operation..."

          yesterday = -1
          page_number = 0

          while yesterday < 1
            page_number +=1
            page.visit oper_link + "?page=#{ page_number }"

            #puts "Get items..."


            item_sections = page.all(:css, '.item:not(.item-top)')

            items = {}
            item_sections.each do |section|
              title = section.all(:css, '.alvi-title a').first
              date = section.all(:css, '.alvi-date').first.text.downcase
              items[title.text] = { href: title[:href], yesterday: date}

            end

            items.each do |item_page, params|
              item_link = params[:href]


              if yesterday == -1 && params[:yesterday] == 'вчера'
                yesterday = 0
              elsif yesterday == 0 && params[:yesterday] != 'вчера'
                yesterday = 1
              end

              puts "page: #{ page_number }   yesterday?: #{ yesterday }    date: #{ params[:yesterday]}    category: #{ category_name }    subcategory: #{ subcategory_name }    title: #{ item_page }"

              #if yesterday == 0

                page.visit item_link
                #page.screenshot_and_open_image

                item = Item.create               s_contact_name:    has_selector?('.avc-name') ? page.find(:css, '.avc-name').text : nil,
                                                 dt_pub_date:       Time.now,
                                                 dt_mod_date:       Time.now,
                                                 s_ip:              "127.0.0.1",
                                                 b_active:          1,
                                                 b_premium:         0,
                                                 b_enabled:         1,
                                                 b_spam:            0,
                                                 s_secret:          (0...5).map{65.+(rand(25)).chr}.join,
                                                 b_show_email:      0,
                                                 dt_expiration:     "9999-12-31 23:59:59",
                                                 b_main_top:        0,
                                                 b_cat_top:         0,
                                                 b_select:          0,
                                                 b_express:         0,
                                                 fk_i_category_id:  category_id(category_name, subcategory_name, operation_name),
                                                 i_price:           has_selector?('.av-price') ? parse_price(page.find(:css, '.av-price').text) : nil,
                                                 fk_c_currency_code: has_selector?('.av-price') ? get_price_code(page.find(:css, '.av-price').text) : nil



                location =  Location.create      fk_i_item_id:       item.id,
                                                 s_phone:            has_selector?('.avc-tels') ? page.find(:css, '.avc-tels').text : nil,
                           fk_c_country_code:  'UA',
                           s_country: 		 'Ukraine',
                                                 s_address:          has_selector?('.av-vals-geo .av-val') ? page.find(:css, '.av-vals-geo .av-val').text : nil


                description = Description.create fk_i_item_id:     item.id,
                                                 s_title:          has_selector?('.content .hl h1') ? page.find(:css, '.content .hl h1').text : nil,
                                                 s_description:    has_selector?('.av-text') ? page.find(:css, '.av-text').text : nil,
                           fk_c_locale_code: 'ru_RU'

                parse_attachments item_link, item.id
              #end
              break #TODO remove this
            end

            break if yesterday == 1

          end

          break #TODO remove this
        end


        break #TODO remove this
      end

      #puts ""
      #puts ""

      break #TODO remove this
    end


  end

  private

  def parse_attachments(link, item_id)

    Capybara.current_driver = :webkit
    Capybara.app_host = 'http://inforico.com.ua'
    page.visit(link)

    if has_selector?('.av-img-all.av-main-img')
      page.find(:css, '.av-img-all.av-main-img').trigger('click')

      page.all(:css, '.avi-thumb').each do |img|
        img.trigger('mouseover')


        big_image = page.find('.avi-image')[:src]
        

        name = (0...5).map{65.+(rand(25)).chr}.join

        resource = Resource.create fk_i_item_id:    item_id,
                                   s_name:          name,
                                   s_extension:     "jpg",
                                   s_content_type:  "image/jpeg",
                                   s_path:          "oc-content/uploads/"

        tempfile_name = "temp/rmagick/#{ name }.jpg"

        File.open(File.join(File.dirname(__FILE__), tempfile_name ), 'wb') do |file|
          file.write open(big_image).read
        end


        source = Magick::Image.read(tempfile_name).first

        source.resize_to_fill(640, 480)
              .write("#{ @app_config['resources_path'] }/#{ resource.id }.jpg")
              .destroy!

        source.resize_to_fill(615, 461)
              .write("#{ @app_config['resources_path'] }/#{ resource.id }_original.jpg")
              .destroy!

        source.resize_to_fill(480, 340)
              .write("#{ @app_config['resources_path'] }/#{ resource.id }_preview.jpg")
              .destroy!

        source.resize_to_fill(240, 200)
              .write("#{ @app_config['resources_path'] }/#{ resource.id }_thumbnail.jpg")
              .destroy!


        File.delete(File.join(File.dirname(__FILE__), tempfile_name ))
      end

    end
    
  end

def category_id (category_name, subcategory_name, operation_name)
                case subcategory_name
                    when "Квартиры и комнаты"
                        if (operation_name == "продам") 
                            return 43
                        elsif (operation_name == "сдам" ) 
                            return 44
                        elsif (operation_name == "сниму") 
                            return 44
                        elsif (operation_name == "куплю") 
                            return 43 
                        elsif (operation_name == "обменяю") 
                            return 46
                        else 
                            return 42                            
                        end                         
                    
                    when "Коммерческая недвижимость"
                        return 50
                    
                    when "Дома, дачи"
                        if (operation_name == "продам") 
                            return 43
                        elsif (operation_name == "сдам" ) 
                            return 44
                        elsif (operation_name == "сниму") 
                            return 44
                        elsif (operation_name == "куплю") 
                            return 
                        elsif (operation_name == "обменяю") 
                            return 46
                        else                                                    
                            return 43
                        end    
                       
                    when "Гаражи, стоянки"
                        return 48

                    when "Недвижимость за рубежом"
                        if (operation_name == "продам") 
                            return 43
                        elsif (operation_name == "сдам" ) 
                            return 44
                        elsif (operation_name == "сниму") 
                            return 44
                        elsif (operation_name == "куплю") 
                            return 43 
                        elsif (operation_name == "обменяю") 
                            return 46
                        else                                                     
                            return 43
                        end    

                    when "Услуги по недвижимости" 
                        return 4
                    
                    when "Другая недвижимость"
                        return 4

                    when "Собаки, щенки"                 
                        return 130

                    when "Кошки, котята"
                        return 131

                    when "Грызуны"
                        return 134

                    when "Рыбки, аквариумы и аксессуары"
                        return 132

                    when "Попугаи, декоративные птицы"
                        return 133

                    when "Сельхоз животные"
                        return 129

                    when "Экзотические животные"
                        return 129

                    when "Рептилии"
                        return 129

                    when "Растения, цветы"
                        return 136

                    when "Ветеринарные препараты"
                        return 135

                    when "Корма и аксессуары"
                        return 135

                    when "Клетки, витрины"
                        return 135

                    when "Услуги для животных"
                        return 135

                    when "Поиски, находки животных"
                        return 135

                    when "Другие животные"
                        return 135

                    when "Легковой транспорт"
                        return 31

                    when "Мотоциклы, мопеды, мототранспорт"
                        return 33

                    when "Велосипеды и аксессуары"
                        return 37

                    when "Коммерческий транспорт"
                        return 36

                    when "Коммунальная техника"
                        return 36

                    when "Сельхозтехника"
                        return 36

                    when "Спецтехника"
                        return 36 

                    when "Авиатранспорт"
                        return 37

                    when "Водный транспорт"
                        return 37

                    when "Автосервис"
                        return 52

                    when "Запчасти и аксессуары для транспортной техники"
                        return 32

                    when "Перевозки"
                        return 59

                    when "Автострахование"
                        return 62

                    when "Другая транспортная техника"
                        return 37

                    when "Техника для дома"
                        return 128

                    when "Климатическая техника"
                        return 128

                    when "Кухонная техника"
                        return 21

                    when "Аудио-, видеотехника"
                        return 127

                    when "Ремонт, обслуживание, услуги"
                        return 60



                end    

                case category_name
                    when "Компьютеры, оргтехника"
                        return 17

                    when "Телефоны и связь"
                        return 15
                    
                    when "Бизнес"
                        return 95

                    when "Работа, учеба"
                        return 95

                    when "Услуги"
                        return 55

                    when "Строительство и ремонт, все для дома"
                        return 81

                    when "Одежда, обувь, аксессуары"
                        return 16

                    when "Детские товары, услуги"
                        return 20

                    when "Красота и здоровье"
                        return 22


                end

                return 30

    end

def parse_price(price)

    if !price
        return 
    end 

    p = price.sub(",","")
    p = p.split[0]
    return p.to_f * 1000000
end

def get_price_code price
    #puts price

    return "ISO" if (/грн/ =~ price)
    return "EUR" if (/€/ =~ price)
    return "USD" if (/$/ =~ price)
    
end


end
