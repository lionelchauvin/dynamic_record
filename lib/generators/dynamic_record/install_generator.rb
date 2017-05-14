require 'rails/generators'
require 'rails/generators/migration'

module DynamicRecord
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    extend ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    def create_model_file
      migration_template "create_dynamic_schema.rb", "db/migrate/create_dynamic_schema.rb"
    end

  end
end
