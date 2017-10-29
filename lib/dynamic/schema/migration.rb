module Dynamic
  module Schema
    module Migration
      autoload :Base, 'dynamic/schema/migration/base'
      autoload :ChangeAttributeType, 'dynamic/schema/migration/change_attribute_type'
      autoload :StringToBoolean, 'dynamic/schema/migration/string_to_boolean'
    end
  end
end
