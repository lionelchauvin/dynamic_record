module Dynamic
  module Schema
    module Attribute
      class TranslatableText < Text
        include Translatable

        module DatabaseManagement; extend ActiveSupport::Concern

          class_methods do

            def column_name_prefix
              'tt'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
