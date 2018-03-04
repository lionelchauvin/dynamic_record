require 'spec_helper'

describe Dynamic::Schema::Migration::ChangeInverseOf do
  before(:each) do
    @schema = Dynamic::Schema::Base.create(name: 'earth')

    @Person = @schema.klasses.create!(name: 'Person')
    @Person.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')

    @Document = @schema.klasses.create!(name: 'Document')
    @Document.attrs.create!(name: 'title', type: 'Dynamic::Schema::Attribute::String')

    @belongs_to = @Document.associations.create!(name: 'owner', type: 'Dynamic::Schema::Association::BelongsTo', target_klass: @Person, schema: @schema)
    @has_many = @Person.associations.create!(name: 'documents', type: 'Dynamic::Schema::Association::HasMany', target_klass: @Document, schema: @schema)

    @migration = @schema.migrations.create!(association: @has_many, type: 'Dynamic::Schema::Migration::ChangeInverseOf')

    @schema.load
  end

  describe 'up' do
    before(:each) do
      @person = D::Earth::Person.create(last_name: 'A')
      @document = @person.documents.create(title: 'CV')
    end

    it 'should create inverse associations' do
      expect{
        @migrate.up
      }.to change {
        @document.owner
      }.from(nil).to{@person}
    end

  end
end
 
