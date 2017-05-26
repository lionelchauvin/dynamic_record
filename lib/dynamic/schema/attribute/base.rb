module Dynamic
  module Schema
    module Attribute
      class Base < ActiveRecord::Base # abstract

        acts_as_paranoid

        self.table_name = 'dynamic_schema_attributes'

        belongs_to :klass, inverse_of: :attrs, touch: true

        validates_presence_of :klass

        module Naming; extend ActiveSupport::Concern

          included do
            translates :human_name, :fallbacks_for_empty_translations => true
            globalize_accessors # human_name_fr, #human_name_en

            before_validation :compute_human_name_en_from_name
            before_validation :compute_name_from_human_name
            validates_uniqueness_of :name, scope: :klass_id
          end

          def human_name_changed?
            self.changed.include?('human_name')
          end

          private

          def compute_human_name_en_from_name
            return if human_name_en.present? || human_name_fr.present? || self.name.blank?
            self.human_name_en = self.name
          end

          def compute_name_from_human_name
            return unless (self.name.blank? && self.human_name.present?) || self.human_name_changed?
            n = self.human_name_en.present? ? self.human_name_en : self.human_name
            self.name = n.underscore.gsub(/\s/, '_')
          end

        end
        include Naming

        module DatabaseManagement; extend ActiveSupport::Concern

          included do
            MAX_INDEXED_COLUMN = 4
            MAX_NOT_INDEXED_COLUMN = 10

            validates_presence_of :column
            before_validation :init_column

            validates_each :column do |record, attr, value|
              if value && value >= (record.index ? record.class::MAX_INDEXED_COLUMN : record.class::MAX_NOT_INDEXED_COLUMN)
                record.errors.add attr, 'column limit exceeded'
              end
            end

            before_real_destroy :nullify_attribute_values

            PRIMITIVE_SUBCLASS_NAMES = [
              'Dynamic::Schema::Attribute::String',
              'Dynamic::Schema::Attribute::Text',
              'Dynamic::Schema::Attribute::Integer',
              'Dynamic::Schema::Attribute::Float',
              'Dynamic::Schema::Attribute::Boolean',
            ].freeze

          end

          class_methods do

            def column_name_prefix
              fail 'abstract class'
            end

            def column_type
              name.demodulize.underscore
            end

          end

          def column_name
            @column_name ||= "#{self.class.column_name_prefix}#{self.index ? 'i' : ''}#{self.column}"
          end

          def const_table_name
            klass.const_table_name
          end

          private

          def init_column
            self.column ||= available_column
          end

          def available_column
            columns = klass.attrs.with_deleted.where(type: self.type, index: self.index).order(:column).select(:column).map(&:column)
            result = 0
            while columns.include?(result) do
              result += 1
            end
            return result
          end

          def nullify_attribute_values
            c = self.class.connection
            c.execute("UPDATE #{c.quote_table_name(const_table_name)} SET #{c.quote_column_name(column_name)} = NULL;")
            return true
          end

        end
        include DatabaseManagement

        module Loading; extend ActiveSupport::Concern

          def load
            load_accessor_methods
          end

          private

          def load_accessor_methods
            klass.const.send(:attribute, self.name, self.class.column_type.to_sym)

            name = self.name
            column_name = self.column_name

            klass.const.send(:define_method, name) do
              send(column_name)
            end

            klass.const.send(:define_method, "#{name}=") do |value|
              attribute_will_change!(name) if value != send(column_name)
              send("#{column_name}=", value)
            end
          end

        end
        include Loading

      end

    end
  end
end
