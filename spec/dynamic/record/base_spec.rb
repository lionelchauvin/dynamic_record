require 'spec_helper'
require 'benchmark'

describe 'Dynamic::Record::Base' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'Uneek')
    @klass = @schema.klasses.create(name: 'Contact')
    @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
    @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')
    @schema.load
    @record = D::Uneek::Contact.create!(last_name: 'Toto', first_name: 'Titi')
  end

  describe "inspect" do

    it 'should contain dynamic attributes' do
      expect(
        @record.inspect.split
      ).to include('last_name:')
    end

    it 'should not contain real colums except id, created_at, updated_at and deleted_at' do
      expect(
        @record.inspect.inspect.split
      ).to_not include('s0:')
    end

  end

  context 'change an attribute' do

    it 'should be dirty' do
      expect(@record).to respond_to(:last_name_changed?)
      expect{
        @record.last_name = 'Berk'
      }.to change{
        @record.last_name_changed?
      }
    end

  end

end
