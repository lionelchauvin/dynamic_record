require 'spec_helper'

describe 'Dynamic::Record dirty' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
  end

  context 'without a translatable attribute' do
    before(:each) do
      @klass = @schema.klasses.create(name: 'City')
      @klass.attrs.create!(name: 'name', type: 'Dynamic::Schema::Attribute::String')
      @schema.load
      @record = D::Earth::City.new
    end

    it 'should have dirty methods' do
      expect(@record).to respond_to(:name_changed?)
    end

    context 'change an attribute' do

      it 'should be marked as changed' do
        expect{
          @record.name = 'Berk'
        }.to change{
          @record.changes
        }.from(
          {}
        ).to(
          {"s0"=>[nil, "Berk"], "name"=>[nil, "Berk"]}
        )
      end

      context 'revert change' do
        before(:each) do
          @record.name = 'Berk'
        end

        it 'should not be marked as changed' do
          expect{
            @record.name = nil
          }.to change{
            @record.changes
          }.from(
            {"s0"=>[nil, "Berk"], "name"=>[nil, "Berk"]}
          ).to(
            {}
          )
        end
      end
    end
  end

  context 'with a translatable attribute' do
    before(:each) do
      @klass = @schema.klasses.create!(human_name_fr: 'Livre', human_name_en: 'Book')
      @attr = @klass.attrs.create!(human_name_fr: 'titre', human_name_en: 'title', type: 'Dynamic::Schema::Attribute::TranslatableString')
      @schema.load
      @record = D::Earth::Book.new
    end

    context 'fr locale' do
      before(:each) do
        @previous_locale = I18n.locale
        I18n.locale = :fr
      end
      after(:each) do
        I18n.locale = @previous_locale
      end

      context 'changed' do

        it 'should mark title, title_fr and column_name as changed' do
          expect{
            @record.title = 'Berk'
          }.to change{
            @record.changes
          }.from(
            {}
          ).to(
            {"title"=>[nil, "Berk"], "title_fr"=>[nil, "Berk"], "ts0"=>[nil, "Berk"]}
          )
        end

        context 'revert change' do
          before(:each) do
            @record.title = 'Berk'
          end

          it 'should not have title, title_fr and column_name marked as changed' do
            expect{
              @record.title = nil
            }.to change{
              @record.changes
            }.from(
              {"title"=>[nil, "Berk"], "title_fr"=>[nil, "Berk"], "ts0"=>[nil, "Berk"]}
            ).to(
              {}
            )
          end
        end

      end

      describe 'title_fr' do

        context 'changed' do

          it 'should mark title, title_fr and column_name as changed' do
            expect{
              @record.title_fr = 'Berk'
            }.to change{
              @record.changes
            }.from(
              {}
            ).to(
              {"title"=>[nil, "Berk"], "title_fr"=>[nil, "Berk"], "ts0"=>[nil, "Berk"]}
            )
          end

          context 'revert change' do
            before(:each) do
              @record.title_fr = 'Berk'
            end

            it 'should not have title, title_fr and column_name marked as changed' do
              expect{
                @record.title_fr = nil
              }.to change{
                @record.changes
              }.from(
                {"title"=>[nil, "Berk"], "title_fr"=>[nil, "Berk"], "ts0"=>[nil, "Berk"]}
              ).to(
                {}
              )
            end
          end

        end

      end

    end

    context 'en locale' do
      before(:each) do
        @previous_locale = I18n.locale
        I18n.locale = :en
      end
      after(:each) do
        I18n.locale = @previous_locale
      end

      describe 'title_fr' do

        context 'changed' do

          it 'should mark title_fr as changed but not title nor column_name' do
            expect{
              @record.title_fr = 'Berk'
            }.to change{
              @record.changes
            }.from(
              {}
            ).to(
              {"title_fr"=>[nil, "Berk"]}
            )
          end

          context 'revert change' do
            before(:each) do
              @record.title_fr = 'Berk'
            end

            it 'should not have title, title_fr, title_en and column_name marked as changed' do
              expect{
                @record.title_fr = nil
              }.to change{
                @record.changes
              }.from(
                {"title_fr"=>[nil, "Berk"]}
              ).to(
                {}
              )
            end
          end

        end

      end

    end

  end

  context 'with a belongs to association' do
    before(:each) do
      @schema = Dynamic::Schema::Base.create!(name: 'earth')
      @klass = @schema.klasses.create!(human_name_fr: 'Personne', human_name_en: 'Person')
      @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
      @association_klass = @klass.associations.create!(name: 'contact', type: 'Dynamic::Schema::Association::BelongsTo', target_klass: @klass, :schema => @schema)
      @schema.load
      @a = D::Earth::Person.create(last_name: 'A')
      @b = D::Earth::Person.create(last_name: 'B')
    end

    context 'change association' do

      it 'should be marked as changed' do
        expect{
          @a.contact = @b
        }.to change{
          @a.changes
        }.from(
          {}
        ).to(
          {"contact_id"=>[nil, @b.id]}
        )
      end

      context 'revert change' do
        before(:each) do
          @a.contact = @b
        end

        it 'should not have association marked as changed' do
          expect{
            @a.contact = nil
          }.to change{
            @a.changes
          }.from(
            {"contact_id"=>[nil, @b.id]}
          ).to(
            {}
          )
        end

      end

      context 'reload' do
        before(:each) do
          @a.contact = @b
        end

        it 'should not have association marked as changed' do
          expect{
            @a.reload
          }.to change{
            @a.changes
          }.from(
            {"contact_id"=>[nil, @b.id]}
          ).to(
            {}
          )
        end

      end
    end

    context 'change association_id' do

      it 'should be marked as changed' do
        expect{
          @a.contact_id = @b.id
        }.to change{
          @a.changes
        }.from(
          {}
        ).to(
          {"contact_id"=>[nil, @b.id]}
        )
      end

    end
  end
end
