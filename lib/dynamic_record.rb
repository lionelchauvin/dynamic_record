require "dynamic/version"

require 'active_record'

require 'globalize'
require 'activemodel-serializers-xml'
require 'globalize-accessors'
require 'acts_as_permalink'
require 'paranoia'

require 'paper_trail/config'
PaperTrail::Config.instance.track_associations = true
require 'paper_trail'

module Dynamic
  autoload :Record, 'dynamic/record'
  autoload :Schema, 'dynamic/schema'
end

