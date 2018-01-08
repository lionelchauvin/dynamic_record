module Dynamic
  module Schema
    module Association
      class HasMany < Base

        module Loading; extend ActiveSupport::Concern

          def load
            n = self.target_klass.const.name

            a = :"#{const_association_name}_associations"

            if self.inverse_of_id

              id = self.inverse_of_id

              self.owner_klass.const.has_many(a, -> {
                where({ schema_association_id: id })
              },{
                class_name: schema.const_assoc_klass.name,
                as: :association_target
              })

              self.owner_klass.const.has_many(const_association_name, {
                class_name: n,
                through: a,
                source: :association_owner,
                source_type: n
              })

            else

              id = self.id

              self.owner_klass.const.has_many(a, -> {
                where({ schema_association_id: id })
              },{
                class_name: schema.const_assoc_klass.name,
                as: :association_owner
              })

              self.owner_klass.const.has_many(const_association_name, {
                class_name: n,
                through: a,
                source: :association_target,
                source_type: n
              })

            end

          end

          def const_association_name
            @const_association_name ||= self.name.underscore.to_sym
          end

        end
        include Loading
    
      end

    end
  end
end
