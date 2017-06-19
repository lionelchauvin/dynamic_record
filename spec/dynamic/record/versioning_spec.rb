require 'spec_helper'

describe 'Dynamic::Record versioning' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
  end

  context 'an attribute' do
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
        expect(
          @record.versions.last.object_deserialized['name']
        ).to eq(
          'Contigwic'
        )
      end

      context 'restore' do
        before(:each) do
          @record.update_attributes(name: 'Condevicnum')
        end

        it 'should have previous attribute' do
          expect{
            @record = @record.paper_trail.previous_version
            @record.save
          }.to change{
            @record.name
          }.from(
            'Condevicnum'
          ).to(
            'Contigwic'
          )
        end

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

  context 'a translatable attribute' do
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

        expect(
          @record.versions.last.object_deserialized['title_fr']
        ).to eq(
          'Le Guide du Routard Galactique'
        )
      end

      context 'restore' do
        before(:each) do
          @record.update_attributes(title_fr: 'Le Guide du Voyageur Galactique')
        end

        it 'should have previous attribute' do
          expect{
            @record = @record.paper_trail.previous_version
            @record.save
          }.to change{
            @record.title_fr
          }.from(
            'Le Guide du Voyageur Galactique'
          ).to(
            'Le Guide du Routard Galactique'
          )
        end

      end

    end

    context 'change and save using a locale' do
      before(:each) do
        I18n.with_locale(:fr) do
          @record.update_attributes(title: 'Le Guide du Voyageur Galactique')
        end
      end

      context 'restore using another locale' do
        before(:each) do
          I18n.with_locale(:en) do
            @record = @record.paper_trail.previous_version
            @record.save
          end
        end

        it 'should properly restore translated attribute' do
          I18n.with_locale(:en) do
            expect(@record.title_fr).to eq("Le Guide du Routard Galactique")
            expect(@record.title_en).to eq("Hitchhiker's Guide to the Galaxy")
            expect(@record.title).to eq("Hitchhiker's Guide to the Galaxy")
          end
        end
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
  end

  context 'an has_many association' do
    before(:each) do
      @klass = @schema.klasses.create!({
        name: 'Book',
        attrs_attributes: [{
          name: 'title',
          type: 'Dynamic::Schema::Attribute::String'
        }]
      })
      @associated_klass = @schema.klasses.create!({
        name: 'Category',
        attrs_attributes: [{
          name: 'name',
          type: 'Dynamic::Schema::Attribute::String'
        }]
      })
      @klass.associations.create!({
        name: 'categories',
        type: 'Dynamic::Schema::Association::HasMany',
        target_klass: @associated_klass,
        schema: @schema
      })
      @schema.load

      @record = D::Earth::Book.create!(title: 'Dune')
      @associated_record = D::Earth::Category.create!(name: 'Science Fiction')
    end

    context 'add an element in the association' do

      it 'should create a new version' do
        expect{
          @record.categories << @associated_record
        }.to change{
          @record.versions.count
        }.by(1)
      end

      context 'restore' do
        before(:each) do
          @record.categories << @associated_record
        end

        it 'should remove the element from the association' do
          expect{
            @record = @record.paper_trail.previous_version #(has_many: true)
            @record.save
          }.to change{
            @record.categories.count
          }.by(-1)
        end

      end

    end

  end

end
