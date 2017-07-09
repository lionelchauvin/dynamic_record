require 'spec_helper'

describe 'Dynamic::Record inheritance' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'Earth')
    @A = @schema.klasses.create(name: 'A')
    @A.attrs.create!(name: 'name', type: 'Dynamic::Schema::Attribute::String')
    @B = @schema.klasses.create(name: 'B', superklass: @A)
    @schema.load
  end

  describe 'a subklass' do

    it 'should inherit from superklass' do
      expect(
        D::Earth::B < D::Earth::A
      ).to eq(true)
    end

    it 'should have same table_name' do
      expect(
        D::Earth::B.table_name
      ).to eq(
        D::Earth::A.table_name
      )
    end

    it 'should inherit from superklass attributes' do
      expect(
        D::Earth::B.new.respond_to?(:name)
      ).to eq(true)
    end

  end

end
