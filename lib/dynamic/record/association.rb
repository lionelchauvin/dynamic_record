module Dynamic
  module Record
    class Association < ActiveRecord::Base
      self.abstract_class = true

      acts_as_paranoid

      belongs_to :association_owner, inverse_of: :dynamic_associations_as_owner, polymorphic: true
      belongs_to :association_target, inverse_of: :dynamic_associations_as_target, polymorphic: true
      belongs_to :schema_association, polymorphic: true, class_name: 'Dynamic::Schema::Association::Base'

      def self.compute_type(name) # hack for create through associations properly
        self
      end

    end
  end
end
