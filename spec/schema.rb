require 'dynamic/schema/installer'

ActiveRecord::Schema.define do
  self.verbose = false

  eval Dynamic::Schema::Installer.migration_content
end
