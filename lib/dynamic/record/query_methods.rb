module Dynamic
  module Record
    module QueryMethods

      module WhereChainNot
        extend ActiveSupport::Concern

        # overide activerecord/lib/active_record/relation/query_methods.rb#L44
        def not(opts, *rest)
          return super unless @scope.respond_to?(:dynamic_mapping) && !opts.blank?

          opts_ = {}
          opts.each do |k,v|
            opts_[@scope.dynamic_mapping[k.to_s] || k] = v
          end
          return super(opts_, *rest)
        end

      end

      class WhereChain < ActiveRecord::QueryMethods::WhereChain
        include Dynamic::Record::QueryMethods::WhereChainNot
      end

      class GlobalizeWhereChain < Globalize::ActiveRecord::QueryMethods::WhereChain
        include Dynamic::Record::QueryMethods::WhereChainNot
      end

      def with_translations_in_fallbacks
        with_translations([I18n.locale])
      end

      def replace_dynamic_attributes(str)
        return str.gsub!(regexp_for_dynamic_attributes, dynamic_mapping) # see dynamic/schema/klass
      end

      # overide activerecord/lib/active_record/relation/query_methods.rb#L599
      def where(opts = :chain, *rest)
        return super unless self.respond_to?(:dynamic_mapping) && !opts.blank?

        if :chain == opts
          if self.respond_to?(:join_translations)
            return Dynamic::Record::QueryMethods::GlobalizeWhereChain.new(spawn)
          else
            return Dynamic::Record::QueryMethods::WhereChain.new(spawn)
          end
        elsif !opts.blank?

          case opts
          when String
            replace_dynamic_attributes(opts)
            return super(opts, *rest)
          when Array
            replace_dynamic_attributes(opts.first)
            return super(opts, *rest)
          when Hash
            opts_ = {}
            opts.each do |k,v|
              opts_[self.dynamic_mapping[k.to_s] || k] = v
            end
            return super(opts_, *rest)
          else
            return super
          end

        end

      end

    end
  end
end

module ActiveRecordClassMethods
  def relation
    super.extending!(Dynamic::Record::QueryMethods)
  end
end
ActiveRecord::Base.extend(ActiveRecordClassMethods)

Globalize::ActiveRecord::QueryMethods.prepend(Dynamic::Record::QueryMethods)
