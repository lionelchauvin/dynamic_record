module Dynamic
  module Schema
    module Migration
      class Base < ActiveRecord::Base # abstract

        acts_as_paranoid

        self.table_name = 'dynamic_schema_migrations'

        enum state: [:todo, :started, :finished, :failed]

        belongs_to :schema, inverse_of: :migrations, class_name: 'Dynamic::Schema::Base'
        belongs_to :klass, :class_name: 'Dynamic::Schema::Klass'
        belongs_to :attr, :class_name: 'Dynamic::Schema::Attribute::Base'

        def start
          self.state = :started
          self.started_at = DateTime.now
        end

        def finish
          self.state = :finished
          self.finished_at = DateTime.now
        end

      end
    end
  end
end
