module Dynamic
  module Schema
    module Attribute
      class String < Base
        
        module DatabaseManagement; extend ActiveSupport::Concern

          included do
            MAX_INDEXED_COLUMN = 6
            MAX_NOT_INDEXED_COLUMN = 20
          end

          class_methods do

            def column_name_prefix
              's'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
