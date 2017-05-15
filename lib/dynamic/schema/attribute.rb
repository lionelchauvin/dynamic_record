module Dynamic
  module Schema
    module Attribute
      autoload :Base, 'dynamic/schema/attribute/base'
      autoload :Boolean, 'dynamic/schema/attribute/boolean'
      autoload :Float, 'dynamic/schema/attribute/float'
      autoload :Integer, 'dynamic/schema/attribute/integer'
      autoload :String, 'dynamic/schema/attribute/string'
      autoload :Text, 'dynamic/schema/attribute/text'
      autoload :Phone, 'dynamic/schema/attribute/phone'
      autoload :Siret, 'dynamic/schema/attribute/siret'
    end
  end
end
