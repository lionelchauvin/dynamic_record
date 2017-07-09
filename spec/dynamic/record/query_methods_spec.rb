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

      @record1 = D::Earth::Book.create!(title_fr: 'Le seigneur des anneaux', title_en: 'The Lord of The Ring')
      @record2 = D::Earth::Book.create!(title_fr: 'Dune', title_en: 'Dune')
    end

    describe 'where' do
      it 'should include record' do
        I18n.with_locale(:fr) do
          expect(D::Earth::Book.where(title: 'Le seigneur des anneaux')).to include(@record1)
          expect(D::Earth::Book.where(title: 'Le seigneur des anneaux')).to_not include(@record2)
        end

        I18n.with_locale(:en) do
          expect(D::Earth::Book.where(title: 'The Lord of The Ring')).to include(@record1)
          expect(D::Earth::Book.where(title: 'The Lord of The Ring')).to_not include(@record2)
        end
      end
    end

    describe 'where.not' do

      it 'should not include record' do
        # In order to make this test pass I overrided with_translations_in_fallbacks in dynamic/record/query_methods.rb

        I18n.with_locale(:fr) do
          expect(D::Earth::Book.where.not(title: 'Le seigneur des anneaux')).to_not include(@record1)
          expect(D::Earth::Book.where.not(title: 'Le seigneur des anneaux')).to include(@record2)
        end

        I18n.with_locale(:en) do
          expect(D::Earth::Book.where.not(title: 'The Lord of The Ring')).to_not include(@record1)
          expect(D::Earth::Book.where.not(title: 'The Lord of The Ring')).to include(@record2)
        end

      end

    end

  end

  context "a translatable attribute accessor" do
    before(:each) do
      @klass = @schema.klasses.create!(human_name_fr: 'Livre', human_name_en: 'Book')
      @klass.attrs.create!(human_name_fr: 'titre', human_name_en: 'title', type: 'Dynamic::Schema::Attribute::TranslatableString')
      @schema.load

      @record1 = D::Earth::Book.create!(title_fr: 'Le seigneur des anneaux', title_en: 'The Lord of The Ring')
      @record2 = D::Earth::Book.create!(title_fr: 'Dune', title_en: 'Dune')
    end

    describe 'where' do
      it 'should include record' do

        # D::Earth::Book.where(title_fr: 'Le seigneur des anneaux'):
        $stderr.puts D::Earth::Book.joins("LEFT JOIN d_earth_books_translations AS d_earth_books_translations_fr ON d_earth_books_translations_fr.locale = 'fr' AND d_earth_books_translations_fr.record_id = d_earth_books.id").where(:"d_earth_books_translations_fr.ts0" => 'Le seigneur des anneaux').inspect

        # TODO:
        # check if a better gem exists
        # or
        # monky patch globalize/query_methods.rb in order to:
        # joins d_earth_books_translations_fr (join_translations)
        # replace title_fr by d_earth_books_translations_fr.ts0 (parse_translated_conditions)

        expect(D::Earth::Book.where(title_fr: 'Le seigneur des anneaux')).to include(@record1)
        expect(D::Earth::Book.where(title_en: 'The Lord of The Ring')).to include(@record1)
      end
    end

    describe 'where.not' do

      it 'should not include record' do
        expect(D::Earth::Book.where.not(title_fr: 'Le seigneur des anneaux')).to_not include(@record1)
        expect(D::Earth::Book.where.not(title_fr: 'Le seigneur des anneaux')).to include(@record2)

        expect(D::Earth::Book.where.not(title_en: 'The Lord of The Ring')).to_not include(@record1)
        expect(D::Earth::Book.where.not(title_en: 'The Lord of The Ring')).to include(@record2)
      end

    end

  end

end
 
