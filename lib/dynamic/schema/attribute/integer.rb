module Dynamic
  module Schema
    module Attribute
      class Integer < Base

        module DatabaseManagement; extend ActiveSupport::Concern

          class_methods do

            def column_name_prefix
              'i'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
