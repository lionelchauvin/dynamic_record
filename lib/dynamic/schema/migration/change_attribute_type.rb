module Dynamic
  module Schema
    module Migration
      class ChangeAttributeType < Base # abstract

        belongs_to :attr, class_name: 'Dynamic::Schema::Attribute::Base'

        before_validation :init_target_attribute_type

        def up
          super do
            reserve_column
            yield
            update_schema
          end
        end

        def target_attribute(reload = false)
          return @target_attribute if @target_attribute && !reload
          @target_attribute = attr.klass.attrs.new(attr.attributes.dup.merge(type: self.target_attribute_type))
          return @target_attribute
        end

        def source_attribute(reload = false)
          self.attr
        end

        private

        def reserve_column

          target_attribute(true).valid?
          column_available = target_attribute.errors.messages[:column].blank?

          if column_available
            update_attributes({
              source_attribute_type: attr.type,
              source_attribute_column: attr.column,
              source_attribute_index: attr.index,
              target_attribute_type: target_attribute.type,
              target_attribute_column: target_attribute.column,
              target_attribute_index: target_attribute.index,
            })
          else
            raise 'NoAvailableColumn' # TODO create an exception
          end
        end

        def update_schema
          self.attr.update_attributes({
            type: target_attribute_type,
            column: target_attribute_column,
            index: target_attribute_index,
          })

          if self.schema.loaded?
            self.schema.unload
            self.schema.load
          end
        end

        def _c(column_name)
          self.class.connection.quote_column_name(column_name)
        end

        def _q(value)
          self.class.connection.quote(value)
        end

      end
    end
  end
end
