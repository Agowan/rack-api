# encoding: utf-8

require 'pg'
require 'byebug'
require File.expand_path('lib/database/connection.rb')

namespace :db do
  desc "Create database"
  task :create do
    envs = ['test', 'development']
    Database::Connection.open do |conn, config|
      res = conn.exec <<-SQL
        CREATE DATABASE "#{config['development']['database']}"
      SQL
      puts res.inspect
    end
  end

  task :drop do
    envs = ['test', 'development']
    Database::Connection.open do |conn, config|
      res = conn.exec <<-SQL
        DROP DATABASE "#{config['development']['database']}"
      SQL
      puts res.inspect
    end
  end

  task :create_migration, :name, :options do
    ARGV.each { |a| task a.to_sym do ; end }
    ARGV.shift
    name = ARGV.first
    filename = "db/migrations/#{DateTime.now.strftime('%Y%d%m%H%M%S')}_#{name}.rb"
    path = File.expand_path("db/migrations/#{DateTime.now.strftime('%Y%d%m%H%M%S')}_#{name}.rb")

    template = File.read(File.expand_path("db/migration_template.txt"))
    klass = name.split('/').collect do |c|
      c.split('_').collect(&:capitalize).join
    end.join('::')
    debugger
    File.open(path, 'w') {|f| f.write(template.gsub(/ClassName/, klass)) }
    puts "Created #{filename}"
  end

  task :migrate do
    filenames = Dir[File.join(File.expand_path("db/migrations/"),'*')].reject { |f| f =~ /base_migration.rb/ }
    Database::Connection.open do |conn, config|
      filenames.each do |path|
        require path
        filename = File.basename(path)
        date = filename.match(/\d{14}/).to_s
        klass = File.read(path).match(/class\s(\w+)/)[1]
        migration = Object::const_get(klass).new
        res = conn.exec(migration.up)
        puts res.inspect
      end
    end
  end
end
