require 'spec_helper'

describe 'Dynamic::Record translation' do
  before(:each) do
    @previous_locale = I18n.locale
    I18n.locale = :fr
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
    @klass = @schema.klasses.create!(human_name_fr: 'Livre', human_name_en: 'Book')
    @attr = @klass.attrs.create!(human_name_fr: 'titre', human_name_en: 'title', type: 'Dynamic::Schema::Attribute::TranslatableString')
    @schema.load
    @record = D::Earth::Book.create(title_fr: "La stratégie Ender", title_en: "Ender's Game")
  end
  after(:each) do
    I18n.locale = @previous_locale
  end

  describe 'title' do

    it 'should have accessors for each locale' do
      expect(@record).to respond_to(:title_fr)
      expect(@record).to respond_to(:"title_fr=")
      expect(@record).to respond_to(:title_en)
      expect(@record).to respond_to(:"title_en=")
    end

    it 'should return a value for each locale' do
      expect(
        I18n.with_locale(:fr){ @record.title }
      ).to eq("La stratégie Ender")
      expect(
        I18n.with_locale(:en){ @record.title }
      ).to eq("Ender's Game")
    end

  end

end
