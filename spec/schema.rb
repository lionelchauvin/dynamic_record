ActiveRecord::Schema.verbose = false
load 'lib/generators/dynamic_record/templates/create_dynamic_schema.rb'
CreateDynamicSchema.new.change
