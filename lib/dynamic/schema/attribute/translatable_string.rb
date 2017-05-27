module Dynamic
  module Schema
    module Attribute
      class TranslatableString < String
        include Translatable

        module DatabaseManagement; extend ActiveSupport::Concern

          class_methods do

            def column_name_prefix
              'ts'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
