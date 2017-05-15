module Dynamic
  module Schema
    module Association
      autoload :Base, 'dynamic/schema/association/base'
      autoload :BelongsTo, 'dynamic/schema/association/belongs_to'
      autoload :HasMany, 'dynamic/schema/association/has_many'
    end
  end
end
