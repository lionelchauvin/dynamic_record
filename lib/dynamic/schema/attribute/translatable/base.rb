module Dynamic
  module Schema
    module Attribute
      module Translatable
        class Base < Dynamic::Schema::Attribute::Base

          module DatabaseManagement; extend ActiveSupport::Concern
            included do
              PRIMITIVE_SUBCLASS_NAMES = [
                'Dynamic::Schema::Attribute::Translatable::String',
                'Dynamic::Schema::Attribute::Translatable::Text',
              ].freeze
            end

            def const_table_name
              klass.const_translation_table_name
            end
          end
          include DatabaseManagement

          module Loading; extend ActiveSupport::Concern

            def load
              load_translations
              super
              I18n.available_locales.each do |locale|
                load_translation_accessor_methods(locale)
              end
            end

            private

            def load_translations
              klass.const.send(:translates, self.column_name, {
                fallbacks_for_empty_translations: true,
                table_name: const_table_name,
                foreign_key: :record_id
              })
            end

            def load_accessor_methods
              klass.const.send(:attribute, self.name, self.class.column_type.to_sym)

              column_name = self.column_name
              name = self.name

              klass.const.send(:define_method, name) do
                send(column_name)
              end

              klass.const.send(:define_method, "#{name}=") do |value|
                #$stderr.puts "#{value.inspect} #{send(column_name).inspect}"
                if value != send(column_name)
                  attribute_will_change!(name)
                  attribute_will_change!("#{name}_#{I18n.locale.to_s.underscore}")
                end
                send("#{column_name}=", value)
              end
            end

            def load_translation_accessor_methods(locale)
              localized_attr_name = localized_attr_name_for(self.name, locale)

              klass.const.send(:attribute, localized_attr_name, self.class.column_type.to_sym)

              attr_name = self.column_name
              name = self.name

              klass.const.send(:define_method, localized_attr_name) do
                globalize.stash.contains?(locale, attr_name) ? globalize.send(:fetch_stash, locale, attr_name) : globalize.send(:fetch_attribute, locale, attr_name)
              end

              klass.const.send(:define_method, "#{localized_attr_name}=") do |value|
                if value != send(localized_attr_name)
                  attribute_will_change!(localized_attr_name)
                  attribute_will_change!(name)
                end
                write_attribute(attr_name, value, :locale => locale)
                translation_for(locale)[attr_name] = value
              end
            end

          end
          include Loading

        end
      end
    end
  end
end 
