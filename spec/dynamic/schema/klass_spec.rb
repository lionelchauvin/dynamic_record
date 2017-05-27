require 'spec_helper'

describe Dynamic::Schema::Klass do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'earth')
  end

  describe 'naming' do

    describe 'create with a human_name' do

      it 'should set a name' do
        expect {
          @klass = @schema.klasses.create!(human_name_fr: 'personne', human_name_en: 'person')
        }.to change {
          @klass.try(:name)
        }.to('Person')
      end

      describe 'create with same human_name' do
        before(:each) do
          @schema.klasses.create!(human_name_fr: 'personne', human_name_en: 'person')
        end

        it 'should not be valid' do
          expect(
            @schema.klasses.create(human_name_fr: 'personne', human_name_en: 'person')
          ).to_not be_valid
        end
      end

      describe 'change human_name_en' do
        before(:each) do
          @klass = @schema.klasses.create!(human_name_fr: 'personne', human_name_en: 'person')
        end

        it 'should change name' do
          expect{
            @klass.update_attributes({human_name_en: 'Contact'})
          }.to change {
            @klass.name
          }.to('Contact')
        end

        it 'should not change permalink' do
          expect{
            @klass.update_attributes({human_name_en: 'Contact'})
          }.to_not change {
            @klass.permalink
          }       
        end

      end

    end
    
  end

  describe 'database management' do

    describe 'create klass' do

      it 'should create table' do
        expect {
          @schema.klasses.create!(name: 'Person')
        }.to change {
          Dynamic::Schema::Base.connection.data_sources
        }.by(['d_earth_people', 'd_earth_people_translations'])
      end

    end

    describe 'destroy klass' do
      before(:each) do
        @klass = @schema.klasses.create!(name: 'Person')
      end

      it 'should rename table' do
        expect {
          @klass.destroy  # resistance is futil
        }.to change {
          Dynamic::Schema::Base.connection.data_sources
        }.by(['d_earth_destroyed_people', 'd_earth_destroyed_people_translations'])
      end

      it 'should keep track of original table name' do
        expect {
          @klass.destroy
        }.to change {
          @klass.original_const_table_name
        }.to('d_earth_people')
      end
    end

    describe 'recreate klass and redestroy' do
      before(:each) do
        @klass = @schema.klasses.create!(name: 'Person')
        @klass.destroy
        @klass = @schema.klasses.create!(name: 'Person')
      end

      it 'should rename table' do
        expect {
          @klass.destroy
        }.to change {
          Dynamic::Schema::Base.connection.data_sources
        }.by(['d_earth_destroyed_people_1', 'd_earth_destroyed_people_1_translations'])
      end

    end

    describe 'destroy a klass having one instance' do
      before(:each) do
        @klass = @schema.klasses.create!(name: 'Person')
        @schema.load
        D::Earth::Person.create!
        @klass.destroy
        @schema.load(:with_deleted => true)
      end

      it 'should still be possible to access to the instance in order to do migration' do
        expect(D::Earth::DestroyedPerson.first).to_not be_nil
      end
    end

    describe 'drop tables' do
      before(:each) do
        @klass = @schema.klasses.create!(name: 'Person')
      end

      it 'should remove table, translation table and versioning table' do
        expect{
          @klass.drop_tables(true)
        }.to change{
          Dynamic::Schema::Base.connection.data_sources.count
        }.by(-2) # by 3 when versioning is ready
      end
    end

  end

end
 
