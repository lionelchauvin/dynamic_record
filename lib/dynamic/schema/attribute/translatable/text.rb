module Dynamic
  module Schema
    module Attribute
      module Translatable
        class Text < Base

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
end 
