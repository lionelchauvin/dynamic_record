module Dynamic
  module Schema
    module Association
      class HasMany < Base

        module Loading; extend ActiveSupport::Concern

          def load
            n = self.target_klass.const.name

            a = :"#{const_association_name}_associations"

            id = self.id

            self.owner_klass.const.has_many(a, -> {
              where({
                schema_association_id: id,
                schema_association_type: 'Dynamic::Schema::Association::Base',
              })
            },{
              class_name: schema.const_assoc_klass.name,
              as: :association_owner,
            })

            has_many_args = {
              class_name: n,
              through: a,
              source: :association_target,
              source_type: n,
            }

            self.owner_klass.const.has_many(const_association_name, has_many_args)

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
