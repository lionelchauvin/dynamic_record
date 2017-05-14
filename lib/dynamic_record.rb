require "dynamic/version"

require 'active_record'

require 'globalize'
require 'activemodel-serializers-xml'
require 'globalize-accessors'
require 'acts_as_permalink'
require 'paranoia'

require 'dynamic/record/base'
require 'dynamic/record/association'
require 'dynamic/record/query_methods'

if ActiveRecord::Base.connection.data_source_exists? 'dynamic_schemas'

  require 'dynamic/schema/base'
  require 'dynamic/schema/klass'

  require 'dynamic/schema/attribute/base'
  Dir["#{File.dirname(__FILE__)}/dynamic/schema/attribute/*.rb"].each {|file| require file }

  require 'dynamic/schema/association/base'
  Dir["#{File.dirname(__FILE__)}/dynamic/schema/association/*.rb"].each {|file| require file }

end

module Dynamic
end
