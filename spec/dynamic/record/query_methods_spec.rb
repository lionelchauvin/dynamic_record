require 'spec_helper'

describe Dynamic::Record::QueryMethods do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
    @klass = @schema.klasses.create!(human_name_fr: 'Personne', human_name_en: 'Person')
    @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')
    @schema.load
    
    @record1 = D::Earth::Person.create!(first_name: 'Charlie')
    @record2 = D::Earth::Person.create!(first_name: 'Toto')
  end

  describe 'where' do

    it 'should include record' do
      expect(D::Earth::Person.where(first_name: 'Charlie')).to include(@record1)
    end

  end

  describe 'where.not' do

    it 'should not include record' do
      expect(D::Earth::Person.where.not(first_name: 'Charlie')).to_not include(@record1)
      expect(D::Earth::Person.where.not(first_name: 'Charlie')).to include(@record2)
    end

  end

end
 
