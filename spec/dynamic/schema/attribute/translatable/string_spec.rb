require 'spec_helper'

describe Dynamic::Schema::Attribute::Translatable::String do
  before(:each) do
    I18n.locale = :fr
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
    @klass = @schema.klasses.create!(human_name_fr: 'Livre', human_name_en: 'Book')
    @attr = @klass.attrs.create!(human_name_fr: 'titre', human_name_en: 'title', type: 'Dynamic::Schema::Attribute::Translatable::String')
    @schema.load
  end

  describe 'D::Earth::Book' do
    before(:each) do
      @record = D::Earth::Book.new
    end

    describe 'title' do

      it 'should have accessors for each locale' do
        expect(@record).to respond_to(:title_fr)
        expect(@record).to respond_to(:"title_fr=")
        expect(@record).to respond_to(:title_en)
        expect(@record).to respond_to(:"title_en=")
      end

      it 'should return a value for each locale' do
        @record = D::Earth::Book.create(title_fr: "La stratégie Ender", title_en: "Ender's Game")

        expect(
          I18n.with_locale(:fr){ @record.title }
        ).to eq("La stratégie Ender")
        expect(
          I18n.with_locale(:en){ @record.title }
        ).to eq("Ender's Game")
      end

      it 'should have dirty methods' do
        expect(@record).to respond_to(:title_changed?)
        expect(@record).to respond_to(:title_en_changed?)
        expect(@record).to respond_to(:title_fr_changed?)
      end

      describe 'changed' do

        it 'should be marked as changed' do
          expect{
            @record.title = 'Berk'
          }.to change{
            @record.title_changed?
          }
        end

        it 'should have also marked title_fr as changed too' do
          expect{
            @record.title = 'Berk'
          }.to change{
            @record.title_fr_changed?
          }
        end

        describe 'revert change' do
          before(:each) do
            @record.title = 'Berk'
          end

          it 'should not have title marked as changed' do
            expect{
              @record.title = nil
            }.to change{
              @record.title_changed?
            }
          end

        end

      end

    end

  end

end
