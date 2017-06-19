require "yaml"

module Dynamic
  module Record
    module VersionSerializer
      extend PaperTrail::Serializers::YAML
      extend self

      def load(string)
        result = ::YAML.load string
        result.delete_if{|k| k =~ Dynamic::Schema::Attribute::Translatable.translated_column_names_regexp}  # don't restore ts0, ts1 because it can have been dumped using another locale
        return result
      end

    end

  end
end
