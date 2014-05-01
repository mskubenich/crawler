namespace :db do

  require 'active_record'
  require 'yaml'
  require 'mysql2'

  desc "Drop and create the current database"

  #task :recreate do
  #  dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml')))
  #  ActiveRecord::Base.establish_connection(dbconfig)
  #  ActiveRecord::Base.connection.recreate_database(ActiveRecord::Base.connection.current_database)
  #end

  task :create do
    dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml')))


    options = {:charset => 'utf8', :collation => 'utf8_unicode_ci'}

    ActiveRecord::Base.establish_connection dbconfig.merge('database' => nil)
    ActiveRecord::Base.connection.create_database dbconfig['database'], options
    #ActiveRecord::Base.establish_connection dbconfig
  end

end