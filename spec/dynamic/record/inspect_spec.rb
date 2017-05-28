require 'spec_helper'

describe 'Dynamic::Record inspect' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'Earth')
    @klass = @schema.klasses.create(name: 'Person')
    @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
    @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')
    @schema.load
    @record = D::Earth::Person.create!(last_name: 'Toto', first_name: 'Titi')
  end

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
