module Dynamic
  module Schema
    class Base < ActiveRecord::Base

      self.table_name = 'dynamic_schemas'

      has_many :klasses, inverse_of: :schema, class_name: 'Dynamic::Schema::Klass', foreign_key: :schema_id, dependent: :destroy
      has_many :associations, inverse_of: :schema, class_name: 'Dynamic::Schema::Association::Base', foreign_key: :schema_id, dependent: :destroy

      validates_presence_of :name

      ROOT_NAME = 'D'

      module DatabaseManagement; extend ActiveSupport::Concern

        included do
          after_create :create_association_table
          include Versioning
        end

        def const_table_prefix
          @const_table_prefix ||= [ROOT_NAME.underscore, name.underscore].join('_')
        end

        def const_assoc_table_name
          @const_assoc_table_name ||= [const_table_prefix, 'dynamic_associations'].join('_')
        end

        private

        def create_association_table
          return if self.class.connection.data_sources.include?(const_assoc_table_name)

          self.class.connection.create_table(const_assoc_table_name) do |t|
            t.references :association_owner, polymorphic: true, index: {name: "index_#{self.id}_da_association_owner"}
            t.references :association_target, polymorphic: true, index: {name: "index_#{self.id}_da_association_target"}
            t.references :schema_association, polymorphic: true, index: {name: "index_#{self.id}_da_schema_association"}
            t.datetime :deleted_at, index: {name: "index_#{self.id}_da_deleted_at"}
          end
          # TODO add multiple index
        end

        module Versioning; extend ActiveSupport::Concern

          included do
            after_create :create_version_table_for_association
          end

          private

          def create_version_table_for_association
            return if self.class.connection.data_sources.include?(const_assoc_version_table_name)

            index_name = "index_d_associations_versions_#{self.id}" # TODO limit to 64
            self.class.connection.create_table(const_assoc_version_table_name) do |t|
              t.integer :version_id, index: true
              t.string :foreign_key_name, null: false
              t.integer :foreign_key_id
              t.index  %i(foreign_key_name foreign_key_id), name: index_name
            end

          end

          def const_assoc_version_table_name
            if false # paper_trail doesn't support several table_names for version_associations :(
              @const_assoc_version_table_name ||= [const_assoc_table_name, 'versions'].join('_')
            else
              'version_associations'
            end
          end

        end

      end
      include DatabaseManagement

      module Loading; extend ActiveSupport::Concern

        def load(options = {})
          return self unless stale?
          const unless loaded?
          if options[:with_deleted]
            klasses.with_deleted.each(&:load)
          else
            klasses.each(&:load)
          end
          self.class.loaded_schemas[name] = self
          return self
        end

        def const
          return @const if @const

          root = Object.const_defined?(ROOT_NAME) ? Object.const_get(ROOT_NAME) : Object.const_set(ROOT_NAME, Module.new)

          name = self.name.titleize.gsub(/\s/, '')

          if root.const_defined?(name)
            root.send(:remove_const, name)
          end
          result = Module.new
          root.const_set(name, result)

          @const = result

          return @const
        end

        def stale?
          return !loaded? || updated_at != updated_at_from_db
        end

        def loaded?
          return self.class.loaded_schemas[name]
        end

        def updated_at_from_db
          self.class.where(id: id).select(:updated_at).first[:updated_at]
        end

        def const_assoc_klass
          return const.const_get('DynamicAssociation') if const.const_defined?('DynamicAssociation')

          result = Class.new(Dynamic::Record::Association)
          result.table_name = const_assoc_table_name
          const.const_set('DynamicAssociation', result)

          return result
        end

        module ClassMethods

          def loaded_schemas
            @loaded_schemas ||= {}
          end

          def load(schema_name, options = {})
            schema = loaded_schemas[schema_name] || find_by_name(schema_name)
            return schema.try(:load)
          end

        end
        extend ClassMethods

      end
      include Loading

    end
  end
end
