module Dynamic
  module Schema
    module Attribute
      class Float < Base

        module DatabaseManagement; extend ActiveSupport::Concern

          class_methods do

            def column_name_prefix
              'f'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
