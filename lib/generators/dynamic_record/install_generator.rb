require 'rails/generators'
module DynamicRecord
  class InstallGenerator < Rails::Generators::Base
    desc "Install migrations for dynamic schema tables"

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

  end
end
