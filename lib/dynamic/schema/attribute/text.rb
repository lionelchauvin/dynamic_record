module Dynamic
  module Schema
    module Attribute
      class Text < Base

        module DatabaseManagement; extend ActiveSupport::Concern

          class_methods do

            def column_name_prefix
              't'
            end

          end

        end
        include DatabaseManagement

      end
    end
  end
end 
