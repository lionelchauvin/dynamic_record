module Dynamic
  module Schema
    module Attribute
      module Translatable; extend ActiveSupport::Concern

        PRIMITIVE_SUBCLASS_NAMES = [
          'Dynamic::Schema::Attribute::TranslatableString',
          'Dynamic::Schema::Attribute::TranslatableText',
        ].freeze

        module DatabaseManagement; extend ActiveSupport::Concern
          def const_table_name
            klass.const_translation_table_name
          end

          class_methods do
            def column_type
              name.demodulize.gsub('Translatable', '').underscore
            end
          end
        end
        include DatabaseManagement

        module Loading; extend ActiveSupport::Concern

          def load
            load_translations
            super # see Dynamic::Schema::Attribute::Base
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

          def load_accessor_methods # redefined
            column_name = self.column_name
            name = self.name
            name_was = :"#{name}_was"
            column_name_setter = :"#{column_name}="
            klass.const.send(:attribute, self.name, self.class.column_type.to_sym)

            klass.const.send(:define_method, name) do
              send(column_name)
            end

            klass.const.send(:define_method, "#{name}=") do |value|
              if value != send(column_name)
                attribute_will_change!(name)
                attribute_will_change!("#{name}_#{I18n.locale.to_s.underscore}")
              end
              if value == send(name_was)
                clear_attribute_changes([name, "#{name}_#{I18n.locale.to_s.underscore}"])
              end

              send(column_name_setter, value)
            end
          end

          def load_translation_accessor_methods(locale)
            localized_attr_name = localized_attr_name_for(self.name, locale)
            attr_name = self.column_name
            name = self.name
            localized_attr_name_was = :"#{localized_attr_name}_was"

            klass.const.send(:attribute, localized_attr_name, self.class.column_type.to_sym)

            klass.const.send(:define_method, localized_attr_name) do
              if globalize.stash.contains?(locale, attr_name)
                return globalize.send(:fetch_stash, locale, attr_name)
              else
                return globalize.send(:fetch_attribute, locale, attr_name)
              end
            end

            klass.const.send(:define_method, "#{localized_attr_name}=") do |value|
              if value != send(localized_attr_name)
                attribute_will_change!(localized_attr_name)
                if I18n.locale == locale
                  attribute_will_change!(name)
                end
              end
              if value == send(localized_attr_name_was)
                clear_attribute_changes([localized_attr_name, name])
              end
              if I18n.locale == locale
                write_attribute(attr_name, value, locale: locale)
              end
              translation_for(locale)[attr_name] = value
            end
          end

        end
        include Loading

        module Versioning; extend ActiveSupport::Concern

          #paper_trail doesn't retrieve values of globalized attributes before they are changed
          #see https://github.com/airblade/paper_trail/blob/a3fa278ef72a5d8160a47bf6f5f806ae6a1ed334/lib/paper_trail/record_trail.rb#L39
          #so we this monkey patch is needed
          module PaperTrailRecordTrailMonkeyPatch; extend ActiveSupport::Concern

            def attributes_before_change
              Hash[@record.attributes.map do |k, v|
                if @record.respond_to?("#{k}_was")
                  [k, attribute_in_previous_version(k)]
                else
                  [k, v]
                end
              end]
            end

          end
          PaperTrail::RecordTrail.prepend(PaperTrailRecordTrailMonkeyPatch)

          # we don't want reify a translated attribute using the wrong locale
          # it will be properly reified using accessors of translated attributes (eq. title_en, title_fr)
          # redefine https://github.com/airblade/paper_trail/blob/a3fa278ef72a5d8160a47bf6f5f806ae6a1ed334/lib/paper_trail/reifier.rb#L102
          PaperTrail::Reifier.class_eval do
            class << self
              def init_unversioned_attrs(attrs, model)
                exceptions = []
                if model.respond_to?(:translated_attribute_names)
                  exceptions = model.translated_attribute_names.map(&:to_s)  # don't init ts0 ts1 ...
                end
                (model.attribute_names - attrs.keys - exceptions).each { |k| attrs[k] = nil }
              end
            end
          end

          PaperTrail.serializer = Dynamic::Record::VersionSerializer

        end
        include Versioning

        def self.translated_column_names_regexp
          return @translated_column_names_regexp if @translated_column_names_regexp

          exceptions_parts = []
          Dynamic::Schema::Attribute::Translatable::PRIMITIVE_SUBCLASS_NAMES.each do |klass_name|
            column_name_prefix = klass_name.constantize.column_name_prefix
            exceptions_parts << "^#{column_name_prefix}[i]?\\d+$" # eg. ts0, ts1 ...
          end

          @regexp_for_translated_column_names = Regexp.new(exceptions_parts.join('|'))
        end

      end
    end
  end
end 
