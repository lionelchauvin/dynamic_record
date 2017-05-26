module Dynamic
  module Schema
    module Association
      class Base < ActiveRecord::Base # abstract

        acts_as_paranoid

        self.table_name = 'dynamic_schema_associations'

        belongs_to :owner_klass, inverse_of: :associations, class_name: 'Dynamic::Schema::Klass', foreign_key: :owner_klass_id
        belongs_to :target_klass, inverse_of: :associations_as_target, class_name: 'Dynamic::Schema::Klass', foreign_key: :target_klass_id
        belongs_to :schema, inverse_of: :associations, class_name: 'Dynamic::Schema::Base', touch: true
        belongs_to :inverse_of, polymorphic: true

        module Naming; extend ActiveSupport::Concern

          included do
            translates :human_name, fallbacks_for_empty_translations: true
            globalize_accessors # human_name_fr, #human_name_en

            before_validation :compute_human_name_en_from_name
            before_validation :compute_name_from_human_name
          end

          def human_name_changed?
            self.changed.include?('human_name')
          end

          def inverse_name # TODO
            "inverse_of_#{self.name}"
          end

          private

          def compute_human_name_en_from_name
            return if human_name_en.present? || human_name_fr.present? || self.name.blank?
            self.human_name_en = self.name
          end

          def compute_name_from_human_name
            return unless (self.name.blank? && self.human_name.present?) || self.human_name_changed?
            n = self.human_name_en.present? ? self.human_name_en : self.human_name
            self.name = n.underscore.gsub(/\s/, '_')
          end

        end
        include Naming

        module Loading; extend ActiveSupport::Concern

          def load
            fail 'abstract class'
          end

        end
        include Loading
    
      end

    end
  end
end
