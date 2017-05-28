require 'spec_helper'

describe 'Dynamic::Record versioning' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
  end

  context 'without a translatable attribute' do
    before(:each) do
      @klass = @schema.klasses.create(name: 'City')
      @klass.attrs.create!(name: 'name', type: 'Dynamic::Schema::Attribute::String')
      @schema.load
      @record = D::Earth::City.create!(name: 'Contigwic')
    end

    it 'should have one version at creation' do
      expect(@record.versions.count).to eq(1)
    end

    context 'change and save' do

      it 'should create a new version' do
        expect{
          @record.name = 'Condevicnum'
          @record.save
        }.to change{
          @record.versions.count
        }.by(1)

        expect(
          @record.versions.last.changeset['name']
        ).to eq(
          ['Contigwic', 'Condevicnum']
        )
      end

    end

    context 'change and save without versioning' do

      it 'should not create a new version' do
        expect{
          @record.name = 'Nantes'
          @record.paper_trail.without_versioning :save
        }.to_not change{
          @record.versions.count
        }
      end

    end

  end

  context 'with a translatable attribute' do
    before(:each) do
      @klass = @schema.klasses.create!(human_name_fr: 'Livre', human_name_en: 'Book')
      @attr = @klass.attrs.create!(human_name_fr: 'titre', human_name_en: 'title', type: 'Dynamic::Schema::Attribute::TranslatableString')
      @schema.load
      @record = D::Earth::Book.create!(title_fr: 'Le Guide du Routard Galactique', title_en: "Hitchhiker's Guide to the Galaxy")
    end

    it 'should have one version at creation' do
      expect(@record.versions.count).to eq(1)
    end

    context 'change and save' do

      it 'should create a new version' do
        expect{
          @record.title_fr = 'Le Guide du Voyageur Galactique'
          @record.save
        }.to change{
          @record.versions.count
        }.by(1)

        expect(
          @record.versions.last.changeset['title_fr']
        ).to eq(
          ['Le Guide du Routard Galactique', 'Le Guide du Voyageur Galactique']
        )
      end

    end

    context 'change and save without versioning' do

      it 'should not create a new version' do
        expect{
          @record.title_fr = 'Le Guide du Voyageur Galactique'
          @record.paper_trail.without_versioning :save
        }.to_not change{
          @record.versions.count
        }
      end

    end

    context 'with a belongs to association' do
      # TODO
    end

  end

end
