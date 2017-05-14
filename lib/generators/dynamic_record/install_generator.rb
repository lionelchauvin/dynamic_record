require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module DynamicRecord
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    source_root File.expand_path('../templates', __FILE__)

    def create_model_file
      migration_template "create_dynamic_schema.rb", "db/migrate/create_dynamic_schema.rb"
    end

  end
end
