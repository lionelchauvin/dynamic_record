require 'dynamic/schema/installer'

namespace :dynamic_record  do
  desc "install dynamic record migration"
  task :install => :environment do
    Dynamic::Schema::Installer.generate_migration    
  end
end
