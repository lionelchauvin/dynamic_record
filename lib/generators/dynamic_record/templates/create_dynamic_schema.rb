class CreateDynamicSchema < ActiveRecord::Migration[5.0]

  def change
    create_table :dynamic_record_schemas do |t|
      t.string :permalink, index: true
      t.string :name
      t.datetime :updated_at
      t.datetime :deleted_at, index: true
    end

    create_table :dynamic_record_klasses do |t|
      t.string :permalink, index: true
      t.string :name
      t.string :const_table_name
      t.string :original_const_table_name
      t.belongs_to :schema, index: true
      t.datetime :deleted_at, index: true
    end

    create_table :dynamic_record_attributes do |t|
      t.string :permalink, index: true
      t.string :name
      t.integer :column
      t.belongs_to :klass, index: true
      t.boolean :index, :default => false
      t.string :type, index: true
      t.datetime :deleted_at, index: true
    end
        
    create_table :dynamic_record_associations do |t|
      t.string :permalink, index: true
      t.string :name
      t.belongs_to :schema, index: true
      t.belongs_to :target_klass, index: true
      t.belongs_to :owner_klass, index: true
      t.references :inverse_of, polymorphic: true, index: {name: 'index_dynamic_record_associations_on_inverse_of_type_and_id'}
      t.string :type, index: true
      t.datetime :deleted_at, index: true
    end
      
    reversible do |dir|
      dir.up do
        Dynamic::Schema::Klass.create_translation_table! :human_name => :string
        Dynamic::Schema::Attribute::Base.create_translation_table! :human_name => :string
        Dynamic::Schema::Association::Base.create_translation_table! :human_name => :string
      end
            
      dir.down do
        Dynamic::Schema::Klass.drop_translation_table!
        Dynamic::Schema::Attribute::Base.drop_translation_table!
        Dynamic::Schema::Association::Base.drop_translation_table!
      end
    end
  end

end
