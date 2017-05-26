module Dynamic
  module Schema

    class Klass < ActiveRecord::Base

      acts_as_paranoid

      self.table_name = 'dynamic_schema_klasses'

      belongs_to :schema, inverse_of: :klasses, class_name: 'Dynamic::Schema::Base', touch: true
      has_many :attrs, inverse_of: :klass, class_name: 'Dynamic::Schema::Attribute::Base', dependent: :destroy
      has_many :associations, inverse_of: :owner_klass,  class_name: 'Dynamic::Schema::Association::Base', foreign_key: :owner_klass_id, dependent: :destroy
      has_many :associations_as_target, inverse_of: :target_klass,  class_name: 'Dynamic::Schema::Association::Base', foreign_key: :target_klass_id, dependent: :destroy

      validates_presence_of :schema

      module Naming; extend ActiveSupport::Concern

        included do
          translates :human_name, fallbacks_for_empty_translations: true
          globalize_accessors # human_name_fr, #human_name_en

          before_validation :compute_human_name_en_from_name

          before_validation :compute_name_from_human_name
          validates_uniqueness_of :name, scope: :schema_id
          validates_presence_of :name

          acts_as_permalink from: :human_name, scope: :schema_id
          validates_presence_of :permalink
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
          self.name = n.titleize.gsub(/\s/, '')
        end

      end
      include Naming

      module DatabaseManagement; extend ActiveSupport::Concern

        included do
          before_validation :compute_const_table_name, on: :create
          validates_presence_of :const_table_name

          after_create :create_table
          after_create :create_translation_table

          before_destroy :rename_table_for_destruction
          before_destroy :rename_translation_table_for_destruction
        end

        def drop_table # for maintenance
          return unless const_table_name.present?
          self.class.connection.drop_table(const_table_name)
        end

        def const_translation_table_name
          "#{const_table_name}_translations"
        end

        private

        attr_accessor :const_table_prefix
        def const_table_prefix
          @const_table_prefix ||= schema.const_table_prefix
        end

        def compute_const_table_name
          result = [const_table_prefix, permalink.pluralize.gsub(/\-/,'_')].join('_')
          i = 1
          while self.class.connection.data_sources.include?(result)
            result = [const_table_prefix, permalink.pluralize.gsub(/\-/,'_'), i].join('_')
            i += 1
          end
          self.const_table_name = result
        end

        def create_table
          return unless const_table_name.present? && !self.class.connection.data_sources.include?(const_table_name)

          self.class.connection.create_table(const_table_name) do |t|
            Attribute::Base::PRIMITIVE_SUBCLASS_NAMES.each do |n|
              k = n.constantize
              for i in 0..(k::MAX_INDEXED_COLUMN - 1)
                t.send(k.column_type, :"#{k.column_name_prefix}i#{i}", index: true)
              end
              for i in 0..(k::MAX_NOT_INDEXED_COLUMN - 1)
                t.send(k.column_type, :"#{k.column_name_prefix}#{i}", index: false)
              end
            end
            t.timestamps
            t.datetime :deleted_at
            t.index :deleted_at
          end
        end

        def create_translation_table
          return unless const_table_name.present? && !self.class.connection.data_sources.include?(const_translation_table_name)

          self.class.connection.create_table("#{const_table_name}_translations") do |t|
            t.integer :record_id
            t.index :record_id, name: "index_d_translations_#{self.class.base_class.name.gsub(/\//, '_').underscore}_#{self.id}"
            Attribute::Translatable::Base::PRIMITIVE_SUBCLASS_NAMES.each do |n|
              k = n.constantize
              for i in 0..(k::MAX_INDEXED_COLUMN - 1)
                t.send(k.column_type, :"#{k.column_name_prefix}i#{i}", index: true)
              end
              for i in 0..(k::MAX_NOT_INDEXED_COLUMN - 1)
                t.send(k.column_type, :"#{k.column_name_prefix}#{i}", index: false)
              end
            end
            t.timestamps
            t.string :locale # indexed ?
          end

        end

        def rename_table_for_destruction
          return false unless const_table_name.present?
          self.original_const_table_name = self.const_table_name
          self.const_table_prefix = [schema.const_table_prefix, 'destroyed'].join('_')
          compute_const_table_name
          result = self.class.connection.rename_table(original_const_table_name, const_table_name)
          result = self.save if result
          return result
        end

        def rename_translation_table_for_destruction
          return self.class.connection.rename_table("#{original_const_table_name}_translations", const_translation_table_name)
        end

        module Translation; extend ActiveSupport::Concern

        end
        include Translation

      end
      include DatabaseManagement

      module Loading; extend ActiveSupport::Concern

        def load
          const
          load_attributes
          load_associations
          return @const
        end

        def const_name
          if deleted?
            # recompute a klass name from table name
            result = (self.const_table_name.gsub(schema.const_table_prefix, '')).classify
          else
            result = name
          end
          return result
        end

        def const
          return @const if @const

          result = Class.new(Dynamic::Record::Base)
          result.table_name = const_table_name
          result.has_many(:dynamic_associations, class_name: schema.const_assoc_klass.name, as: :association_owner)
          result.has_many(:dynamic_associations_as_target, class_name: schema.const_assoc_klass.name, as: :association_target)

          schema.const.const_set(const_name, result)

          @const = result
          return @const
        end

        private

        def load_attributes
          self.attrs.each(&:load)
          attrs_ = self.attrs

          dynamic_attribute_types = {'id' => 'integer'}
          self.attrs.each do |attr|
            dynamic_attribute_types[attr.name] = attr.class.column_type
          end

          const.send(:define_singleton_method, 'dynamic_attribute_types') do
            return dynamic_attribute_types
          end

          dynamic_mapping = {}
          self.attrs.each do |attr|
            dynamic_mapping[attr.name.to_sym] = attr.column_name.to_sym
          end

          const.send(:define_singleton_method, 'dynamic_mapping') do
            return dynamic_mapping
          end
        end

        def load_associations
          self.associations.each(&:load)
        end

      end
      include Loading

    end
  end
end
