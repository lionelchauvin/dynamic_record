require 'spec_helper'

describe Dynamic::Schema::Attribute::Base do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
  end

  describe 'naming' do
    before(:each) do
      @klass = @schema.klasses.create!(human_name_fr: 'Personne', human_name_en: 'Person')
    end

    describe 'create with a human_name' do

      it 'should set a name' do
        expect {
          @attr = @klass.attrs.create!(human_name_fr: 'Nom de famille', human_name_en: 'Last name', :type => 'Dynamic::Schema::Attribute::String')
        }.to change {
          @attr.try(:name)
        }.to('last_name')
      end

      describe 'create with same human_name' do
        before(:each) do
          @klass.attrs.create!(human_name_fr: 'Nom de famille', human_name_en: 'Last name', :type => 'Dynamic::Schema::Attribute::String')
        end

        it 'should not be valid' do
          expect(
            @klass.attrs.create(human_name_fr: 'Nom de famille', human_name_en: 'last name', :type => 'Dynamic::Schema::Attribute::String')
          ).to_not be_valid
        end

      end

    end

  end

  describe 'database management' do
    before(:each) do
      @klass = @schema.klasses.create!(human_name_fr: 'Personne', human_name_en: 'Person')
    end

    describe 'create attribute' do
      before(:each) do
        @first_attr = @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
      end

      it 'should assign a column' do
        expect(@first_attr.column).to eq(0)
      end

      describe 'create another attribute' do
        before(:each) do
          @second_attr = @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')
        end

        it 'should assign next column' do
          expect(@second_attr.column).to eq(1)  
        end
      end
    end

    describe 'destroy attribute' do
      before(:each) do
        @first_attr = @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
        @second_attr = @klass.attrs.create!(name: 'first_name', type: 'Dynamic::Schema::Attribute::String')

        @schema.load unless @schema.loaded?
        D::Earth::Person.create(:last_name => 'A')
        D::Earth::Person.create(:last_name => 'B')
      end

      it 'should keep attribute values' do
        expect{
          @first_attr.destroy!
        }.to_not change{
          D::Earth::Person.all.map(&:last_name)
        }
      end

      describe 'recreate' do
        before(:each) do
          @first_attr.destroy
        end

        it 'should not reuse a column' do
          expect(@klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String').column).to_not eq(0)
        end
      end

      describe 'really destroy' do

        it 'should nullify attribute values' do
          expect{
            @first_attr.really_destroy!
          }.to change{
            D::Earth::Person.all.map(&:last_name).sort
          }.from(['A', 'B']).to([nil, nil])
        end

        describe 'recreate' do
          before(:each) do
            @first_attr.really_destroy!
          end

          it 'should reuse column' do
            expect(@klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String').column).to eq(0)
          end
        end

      end

    end

    describe 'use all available columns' do
      before(:each) do
#         raise Dynamic::Schema::Attribute::String::MAX_NOT_INDEXED_COLUMN.inspect
        for i in 0..(Dynamic::Schema::Attribute::String::MAX_NOT_INDEXED_COLUMN - 1) do
          @klass.attrs.create!(name: i.to_s, type: 'Dynamic::Schema::Attribute::String')
        end
      end

      describe 'create a new attribute' do
        it 'should not be valid' do
          expect(@klass.attrs.create(name: 'droplet', type: 'Dynamic::Schema::Attribute::String')).to_not be_valid
        end
      end

    end

  end

end
