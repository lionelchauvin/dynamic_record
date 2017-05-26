require 'spec_helper'
require 'benchmark'

describe 'Benchmark' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'Uneek')
    @schema.klasses.create(name: 'Contact')
    @schema.load
    @klass = D::Uneek::Contact
  end

=begin
  it "creation of many instances" do
    i = 0
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    $stderr.puts Benchmark.measure {
      begin
        attrs = {}
        @klass.column_names.each do |c|
          next if c == 'id'
          attrs[c] = (0...50).map { o[rand(o.length)] }.join
        end

        @klass.create(attrs)
        i+=1
      end while i < 1000
    }

    $stderr.puts Benchmark.measure {
      @klass.all
    }
  end
=end

end
