require 'spec_helper'

describe Dynamic::Schema::Migration::StringToBoolean do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'earth')
    @klass = @schema.klasses.create!(human_name_fr: 'Personne', human_name_en: 'Person')
    @klass.attrs.create!(human_name_fr: 'Nom de famille', human_name_en: 'Last name', type: 'Dynamic::Schema::Attribute::String')
    @attr = @klass.attrs.create!(human_name_fr: 'data', human_name_en: 'data', type: 'Dynamic::Schema::Attribute::String')
    @migration = @schema.migrations.create!(attr: @attr, type: 'Dynamic::Schema::Migration::StringToBoolean')
    @schema.load
  end

  describe 'up' do
    before(:each) do
      @p = D::Earth::Person.create(data: 'Oui')
    end

    it 'should reserve column' do
      expect{
        @migration.up
      }.to change{
        @migration.target_attribute_column
      }
    end

    it 'should migrate data' do
      expect{
        @migration.up
        @p = D::Earth::Person.find(@p.id)
      }.to change{
        @p.data
      }.from('Oui').to(true)
    end
  end
end
 
