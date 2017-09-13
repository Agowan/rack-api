require 'yaml'

module Database
  class Connection
    class << self
      def open
        config = YAML.load_file(File.expand_path('config/database.yml'))
        begin
          conn = PG::Connection.open(dbname: config['development']['database'])
          yield(conn, config)
        rescue Exception => e
          puts e.message
        ensure
          conn.close
        end
      end
    end
  end
end
