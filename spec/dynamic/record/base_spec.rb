require 'spec_helper'
require 'benchmark'

describe 'Dynamic::Record::Base' do

  context "benchmark" do
    before(:each) do
      @schema = Dynamic::Schema::Base.create(name: 'Uneek')
      @schema.klasses.create(name: 'Contact')
      @schema.load
      @klass = D::Uneek::Contact
    end

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

  end

  context "inspect" do
    before(:each) do
      @schema = Dynamic::Schema::Base.create(name: 'Uneek')
      @klass = @schema.klasses.create(name: 'Contact')
      @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
      @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')
      @schema.load
      @record = D::Uneek::Contact.create!(last_name: 'Toto', first_name: 'Titi')
    end

    it 'should contain dynamic attributes' do
      expect(
        @record.inspect.inspect.split
      ).to include('last_name:')
    end

    it 'should not contain real colums except id, created_at, updated_at and deleted_at' do
      expect(
        @record.inspect.inspect.split
      ).to_not include('s0:')
    end
  end
end
