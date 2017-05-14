module Dynamic
  module Record 
    class Base < ActiveRecord::Base
      self.abstract_class = true

      acts_as_paranoid

      module Inspector; extend ActiveSupport::Concern

        def dynamic_attribute_names
          self.class.dynamic_attribute_types.keys
        end

        def inspect
          string = "#<#{self.class.name} "
          fields = dynamic_attribute_names.map{|field| "#{field}: #{self.send(field).inspect}"}
          fields << "created_at: #{self.created_at ? self.created_at : 'nil'}"
          fields << "updated_at: #{self.updated_at ? self.updated_at : 'nil'}"
          fields << "deleted_at: #{self.deleted_at ? self.deleted_at : 'nil'}"
          string << fields.join(", ") << '>'
        end

        class_methods do
          def inspect
            string = "#{self.name}("
            fields = self.dynamic_attribute_types.map{|field, type| "#{field}: #{type}"}
            fields << "created_at: datetime"
            fields << "updated_at: datetime"
            fields << "deleted_at: datetime"
            string << fields.join(", ") << ')'
          end
        end

      end
      include Inspector

    end
  end
end
