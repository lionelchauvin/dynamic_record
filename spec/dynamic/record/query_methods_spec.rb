require 'spec_helper'

describe Dynamic::Record::QueryMethods do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
  end

  context "an attribute" do
    before(:each) do
      @klass = @schema.klasses.create!(name: 'Person')
      @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')
      @schema.load

      @record1 = D::Earth::Person.create!(first_name: 'Charlie')
      @record2 = D::Earth::Person.create!(first_name: 'Toto')
    end

    describe 'where' do

      it 'should include record' do
        expect(D::Earth::Person.where(first_name: 'Charlie')).to include(@record1)
      end

      context 'with a string condition' do
        it 'should include record' do
          expect(D::Earth::Person.where(['first_name = ?', 'Charlie'])).to include(@record1)
          expect(D::Earth::Person.where('first_name IS NOT NULL')).to include(@record1)
        end
      end

    end

    describe 'where.not' do

      it 'should not include record' do
        expect(D::Earth::Person.where.not(first_name: 'Charlie')).to_not include(@record1)
        expect(D::Earth::Person.where.not(first_name: 'Charlie')).to include(@record2)
      end

    end

  end

  context "a translatable attribute" do
    before(:each) do
      @klass = @schema.klasses.create!(human_name_fr: 'Livre', human_name_en: 'Book')
      @klass.attrs.create!(human_name_fr: 'titre', human_name_en: 'title', type: 'Dynamic::Schema::Attribute::TranslatableString')
      @schema.load

      @record1 = D::Earth::Book.create!(title: 'Dune')
      @record2 = D::Earth::Book.create!(title: 'The Lord of The Ring')
    end

    describe 'where' do
      it 'should include record' do
        expect(D::Earth::Book.where(title: 'Dune')).to include(@record1)
      end
    end

    describe 'where.not' do

      it 'should not include record' do
        expect(D::Earth::Book.where.not(title: 'Dune')).to_not include(@record1)
        expect(D::Earth::Book.where.not(title: 'Dune')).to include(@record2)
      end

    end

  end

end
 
