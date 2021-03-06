module Dynamic
  module Record
    class Association < ActiveRecord::Base
      self.abstract_class = true

      acts_as_paranoid

      belongs_to :association_owner, inverse_of: :dynamic_associations, polymorphic: true
      belongs_to :association_target, inverse_of: :dynamic_associations_as_target, polymorphic: true
      belongs_to :schema_association, polymorphic: true, class_name: 'Dynamic::Schema::Association::Base'

      class << self
        def compute_type(name) # hack for create through associations properly
          self
        end

        attr_accessor :has_inverse # set when schema is loaded (prevent additional queries when create/destroy inverse)
      end

      validates_uniqueness_of :association_owner_id, scope: [
        :association_owner_type,
        :association_target_id,
        :association_target_type,
        :schema_association_id,
        :schema_association_type,
        :deleted_at,
      ]

      attr_accessor :skip_inverse

      after_create :create_inverse, :if => :has_inverse?
      after_destroy :destroy_inverse, :if => :has_inverse?

      def create_inverse
        self.class.create({
          association_owner: association_target,
          association_target_id: association_owner_id,
          association_target_type: association_owner_type,
          schema_association_id: self.class.has_inverse[schema_association_id],
          schema_association_type: 'Dynamic::Schema::Association::Base',
          skip_inverse: true, # cut circular inverse creation
        })
      end

      def destroy_inverse
        self.class.where({
          association_owner: association_target,
          association_target_id: association_owner_id,
          association_target_type: association_owner_type,
          schema_association_id: self.class.has_inverse[schema_association_id],
          schema_association_type: 'Dynamic::Schema::Association::Base',
        }).destroy_all
      end

      def has_inverse?
        !skip_inverse && self.class.has_inverse && self.class.has_inverse[schema_association_id]
      end

    end
  end
end
