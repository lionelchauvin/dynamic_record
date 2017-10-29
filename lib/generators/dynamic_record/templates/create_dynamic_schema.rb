class CreateDynamicSchema < ActiveRecord::Migration[5.0]

  def change

    create_table :dynamic_schemas do |t|
      t.string :permalink, index: true
      t.string :name
      t.datetime :updated_at
      t.datetime :deleted_at, index: true
    end

    create_table :dynamic_schema_klasses do |t|
      t.string :permalink, index: true
      t.string :name
      t.string :const_table_name
      t.string :original_const_table_name
      t.belongs_to :schema, index: true
      t.belongs_to :superklass, index: true
      t.belongs_to :baseklass, index: true
      t.integer :depth
      t.boolean :versioned, default: true
      t.timestamps
      t.datetime :deleted_at, index: true
    end

    create_table :dynamic_schema_attributes do |t|
      t.string :permalink, index: true
      t.string :name
      t.integer :column
      t.belongs_to :klass, index: true
      t.belongs_to :baseklass, index: true
      t.boolean :index, :default => false
      t.string :type, index: true
      t.timestamps
      t.datetime :deleted_at, index: true
    end

    create_table :dynamic_schema_associations do |t|
      t.string :permalink, index: true
      t.string :name
      t.belongs_to :schema, index: true
      t.belongs_to :target_klass, index: true
      t.belongs_to :owner_klass, index: true
      t.references :inverse_of, polymorphic: true, index: {name: 'index_dynamic_schema_associations_on_inverse_of_type_and_id'}
      t.string :type, index: true
      t.timestamps
      t.datetime :deleted_at, index: true
    end

    create_table :dynamic_schema_klass_translations  do |t|
      t.integer :dynamic_schema_klass_id, index: {name: 'index_dynamic_schema_klass_translations_klass_id'}
      t.string :human_name
      t.string :locale
    end

    create_table :dynamic_schema_attribute_translations  do |t|
      t.integer :dynamic_schema_attribute_id, index: {name: 'index_dynamic_schema_klass_translations_attribute_id'}
      t.string :human_name
      t.string :locale
    end

    create_table :dynamic_schema_association_translations  do |t|
      t.integer :dynamic_schema_association_id, index: {name: 'index_dynamic_schema_klass_translations_association_id'}
      t.string :human_name
      t.string :locale
    end

    create_table :dynamic_schema_migrations  do |t|
      t.integer :state, default: 0, index: true
      t.integer :progress, default: 0
      t.integer :total, default: 1
      t.belongs_to :schema, index: true
      t.belongs_to :klass
      t.belongs_to :attr
      t.string :source_attribute_type
      t.integer :source_attribute_column
      t.boolean :source_attribute_index
      t.string :target_attribute_type
      t.integer :target_attribute_column
      t.boolean :target_attribute_index
      t.string :type, index: true
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
      t.datetime :deleted_at, index: true
    end

  end

end
