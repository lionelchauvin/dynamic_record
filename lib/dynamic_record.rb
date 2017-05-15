require "dynamic/version"

require 'active_record'

require 'globalize'
require 'activemodel-serializers-xml'
require 'globalize-accessors'
require 'acts_as_permalink'
require 'paranoia'

module Dynamic
  autoload :Record, 'dynamic/record'
  autoload :Schema, 'dynamic/schema'
end
