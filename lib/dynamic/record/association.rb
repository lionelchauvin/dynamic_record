module Dynamic
  module Record
    class Association < ActiveRecord::Base
      self.abstract_class = true

      acts_as_paranoid

      belongs_to :association_owner, inverse_of: :dynamic_associations, polymorphic: true
      belongs_to :association_target, inverse_of: :dynamic_associations_as_target, polymorphic: true
      belongs_to :schema_association, polymorphic: true, class_name: 'Dynamic::Schema::Association::Base'

      def self.compute_type(name) # hack for create through associations properly
        self
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
          association_target: association_owner,
          schema_association: schema_association.inverse_of,
          skip_inverse: true, # cut circular inverse creation
        })
      end

      def destroy_inverse
        self.class.destroy_all({
          association_owner: association_target,
          association_target: association_owner,
          schema_association: schema_association.inverse_of,
          skip_inverse: true, # cut circular inverse destruction
        })
      end

      def has_inverse?
        !skip_inverse && schema_association&.inverse_of_id
      end

    end
  end
end
