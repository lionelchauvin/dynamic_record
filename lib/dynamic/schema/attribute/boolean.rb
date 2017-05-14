module Dynamic
  module Schema
    module Attribute
      class Boolean < Base

        module DatabaseManagement; extend ActiveSupport::Concern

          included do
            MAX_INDEXED_COLUMN = 2
          end

          class_methods do

            def column_name_prefix
              'b'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
