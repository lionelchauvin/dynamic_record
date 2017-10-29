module Dynamic
  module Schema
    module Migration
      class Base < ActiveRecord::Base # abstract

        acts_as_paranoid

        self.table_name = 'dynamic_schema_migrations'

        enum state: [:todo, :started, :finished, :failed]

        belongs_to :schema, inverse_of: :migrations, class_name: 'Dynamic::Schema::Base'

        def up
          start
          yield
          finish
        end

        private

        def start
          update_attributes(state: :started, started_at: DateTime.now)
        end

        def finish
          update_attributes(state: :finished, finished_at: DateTime.now)
        end

      end
    end
  end
end
