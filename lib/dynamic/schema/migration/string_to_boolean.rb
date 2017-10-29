module Dynamic
  module Schema
    module Migration
      class StringToBoolean < ChangeAttributeType

        MAPPING = {
          'oui' => '1',
          'non' => '0',
          'yes' => '1',
          'no' => '0',
        }

        def up
          super do
            self.class.connection.execute("UPDATE #{_q(attr.klass.const_table_name)} SET #{mapping_sql}")
          end
        end

        private

        def mapping_sql
          result = ["#{_c(self.target_attribute.column_name)} = CASE LOWER(TRIM(#{_c(self.source_attribute.column_name)}))"]
          MAPPING.each do |k,v|
            result << "WHEN #{_q(k)} THEN #{_q(v)}"
          end
          result << "END"
          return result.join(' ')
        end

        def init_target_attribute_type
          self.target_attribute_type = 'Dynamic::Schema::Attribute::Boolean'
        end

      end
    end
  end
end
