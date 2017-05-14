require 'spec_helper'

describe Dynamic::Schema::Association::HasMany do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
    @Person = @schema.klasses.create!(name: 'Person')
    @Person.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')

    @Document = @schema.klasses.create!(name: 'Document')    
    @Document.attrs.create!(name: 'title', type: 'Dynamic::Schema::Attribute::String')

    @belongs_to = @Document.associations.create!(name: 'owner', type: 'Dynamic::Schema::Association::BelongsTo', target_klass: @Person, schema: @schema)
    @has_many = @Person.associations.create!(name: 'documents', type: 'Dynamic::Schema::Association::HasMany', target_klass: @Document, inverse_of: @belongs_to, schema: @schema)

    @schema.load
  end

  describe 'create through an association' do
    before(:each) do
      @a = D::Earth::Person.create(last_name: 'A')
      expect(@a).to respond_to(:documents)
    end

    it 'should create a dynamic_association' do
      expect {
        @a.documents.create!(title: 'CV')
        @a.dynamic_associations.reload
      }.to change {
        @a.dynamic_associations.length
      }.by(1)
    end
  end

  describe 'create a DynamicAssociation' do
    before(:each) do
      @a = D::Earth::Person.create(last_name: 'A')
      @d = D::Earth::Document.create(title: 'CV')
    end

    it 'should change dynamic_associations' do
      expect {
        D::Earth::DynamicAssociation.create!(association_owner: @a, association_target: @d, schema_association: @has_many)
        @a.dynamic_associations.reload
      }.to change {
        @a.dynamic_associations.length
      }.by(1)
    end

    it 'should change association' do      
# TODO why it doesn't work ?
#       expect {
      #         c = D::Earth::DynamicAssociation.create!(association_owner: @a, association_target: @d, schema_association: @has_many)
#         @a.documents.reload
#       }.to change {
#         @a.documents.to_a
#       }.to([@b])
#       
      expect {
        c = D::Earth::DynamicAssociation.create!(association_owner: @a, association_target: @d, schema_association: @has_many)
        @a.documents.reload
      }.to change {
        @a.documents.map(&:id)
      }.to([@d.id])
    end

  end

  describe 'with inverse of, create throuth an assocation' do
    before(:each) do
      @a = D::Earth::Person.create(last_name: 'A')
      @a.documents.create!(title: 'CV')
    end

    it 'should set inverse association' do
      # TODO
      expect(@a.documents.first.owner).to eq(@a)
    end

  end

end
 
