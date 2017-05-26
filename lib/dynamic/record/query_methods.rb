module Dynamic
  module Record
    module QueryMethods
      extend ActiveSupport::Concern

      class WhereChain < ActiveRecord::QueryMethods::WhereChain
        
        # overide activerecord/lib/active_record/relation/query_methods.rb#L44
        def not(opts, *rest)
          return super unless @scope.respond_to?(:dynamic_mapping) && !opts.blank?
          opts_ = {}
          opts.each do |k,v|
            opts_[@scope.dynamic_mapping[k] || k] = v
          end
          return super(opts_, *rest)
        end

      end

      # overide activerecord/lib/active_record/relation/query_methods.rb#L599
      def where(opts = :chain, *rest)
        return super unless self.respond_to?(:dynamic_mapping) && !opts.blank?

        if :chain == opts
          return WhereChain.new(spawn)
        elsif !opts.blank?
          opts_ = {}
          opts.each do |k,v|
            opts_[self.dynamic_mapping[k] || k] = v
          end
          return super(opts_, *rest)
        end

      end

    end
  end  
end

ActiveRecord::Relation.include(Dynamic::Record::QueryMethods)
