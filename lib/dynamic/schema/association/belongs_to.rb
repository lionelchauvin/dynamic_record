module Dynamic
  module Schema
    module Association
      class BelongsTo < Base

        module Loading; extend ActiveSupport::Concern

          def load
            define_an_has_one_in_order_to_fake_a_belongs_to_through
            define_accessor_methods
            define_build_method
            define_validation_of_associated_records
            define_save_of_associated_records
            redefine_reload
          end

          def const_association_name
            @const_association_name ||= self.name.underscore.to_sym
          end

          private

          def define_an_has_one_in_order_to_fake_a_belongs_to_through
            id = self.id
            a = :"#{const_association_name}_association"
            n = self.target_klass.const.name

            self.owner_klass.const.has_one(a, -> {
              where({
                schema_association_id: id,
                schema_association_type: 'Dynamic::Schema::Association::Base',
              })
            },{
              class_name: schema.const_assoc_klass.name,
              as: :association_owner,
            })

            self.owner_klass.const.has_one(const_association_name, {
              class_name: n,
              through: a,
              source: :association_target,
              source_type: n,
            })

          end

          def define_accessor_methods
            can = const_association_name
            a = :"#{const_association_name}_association"
            can_id = :"#{can}_id"
            can_id_setter = :"#{can}_id="
            cached_can = :"cached_#{can}"

            self.owner_klass.const.send(:define_method, const_association_name) do
              return @changed_belongs_to[can] if @changed_belongs_to && @changed_belongs_to[can]
              return send(a).try(:association_target)
            end

            self.owner_klass.const.send(:define_method, :"#{const_association_name}=") do |t|
              @changed_belongs_to ||= {}
              @changed_belongs_to[can] = t

              @belongs_to_new_record_to_save ||= {}
              if t&.new_record?
                @belongs_to_new_record_to_save[can] = t
              else
                @belongs_to_new_record_to_save.delete(can)
              end

              self.send(can_id_setter, t.try(:id))
            end

            self.owner_klass.const.attribute(can_id, :integer)

            self.owner_klass.const.send(:define_method, :"cached_#{const_association_name}") do
              return @cached_belongs_to[can] if @cached_belongs_to && @cached_belongs_to.has_key?(can)
              @cached_belongs_to ||= {}
              @cached_belongs_to[can] = send(a).try(:association_target)
              return @cached_belongs_to[can]
            end

            self.owner_klass.const.send(:define_method, can_id) do
              return @belongs_to_id_to_save[can] if @belongs_to_id_to_save && @belongs_to_id_to_save.has_key?(can)
              return send(cached_can).try(:id)
            end

            self.owner_klass.const.send(:define_method, can_id_setter) do |id|
              @belongs_to_id_to_save ||= {}
              unless id == send(cached_can).try(:id)
                attribute_will_change!(can_id)
              else
                self.clear_attribute_changes([can_id])
              end
              @belongs_to_id_to_save[can] = id
            end
          end

          def define_build_method
            can = const_association_name
            target_klass_const = self.target_klass.const
            self.owner_klass.const.send(:define_method, :"build_#{const_association_name}") do |args|
              t = target_klass_const.new(args)
              self.send("#{can}=", t)
              return t
            end
          end

          def define_validation_of_associated_records
            return if self.owner_klass.const.respond_to?(:validate_records_of_dynamic_belongs_to_associations, :include_private)

            self.owner_klass.const.send(:define_method, :validate_records_of_dynamic_belongs_to_associations) do
              return true unless @changed_belongs_to.try(:any?)
              invalid_records = []
              @changed_belongs_to.values.each do |r|
                invalid_records << r unless r.try(:valid?)
              end
              raise ActiveRecord::RecordInvalid unless invalid_records.empty?
              return true
            end
            self.owner_klass.const.send(:private, :validate_records_of_dynamic_belongs_to_associations)
            self.owner_klass.const.before_save(:validate_records_of_dynamic_belongs_to_associations)
          end

          def define_save_of_associated_records
            return if self.owner_klass.const.respond_to?(:save_records_of_dynamic_belongs_to_associations, :include_private)

            t =  self.target_klass.const.base_class.name

            self.owner_klass.const.send(:define_method, :save_records_of_dynamic_belongs_to_associations) do
              return true unless @belongs_to_id_to_save.try(:any?) || @belongs_to_new_record_to_save.try(:any?)

              if @belongs_to_new_record_to_save
                @belongs_to_new_record_to_save.each do |k,r|
                  if r.save
                    ca = send(:"#{k}_association")
                    if ca
                      ca.association_target = r
                      ca.save
                    else
                      send(:"create_#{k}_association", association_target: r)
                    end
                  end
                end
              end

              if @belongs_to_id_to_save
                @belongs_to_id_to_save.each do |k, id|
                  ca = send(:"#{k}_association")
                  if ca
                    ca.association_target_id = id
                    ca.association_target_type = t
                    ca.save
                  else
                    send(:"create_#{k}_association", association_target_id: id, association_target_type: t)
                  end
                end
              end

              return true
            end
            self.owner_klass.const.send(:private, :save_records_of_dynamic_belongs_to_associations)
            self.owner_klass.const.after_save(:save_records_of_dynamic_belongs_to_associations)
          end

          module Reloading

            def reload
              @belongs_to_id_to_save = {}
              @belongs_to_new_record_to_save = {}
              @changed_belongs_to = {}
              @cached_belongs_to = {}
              super
            end

          end

          def redefine_reload
            self.owner_klass.const.send(:prepend, Reloading)
          end

        end
        include Loading

      end

    end
  end
end
