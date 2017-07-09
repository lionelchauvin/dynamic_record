require 'spec_helper'

describe 'Dynamic::Record belongs_to association' do
  before(:each) do
    @schema = Dynamic::Schema::Base.create!(name: 'earth')
    @klass = @schema.klasses.create!(human_name_fr: 'Personne', human_name_en: 'Person')
    @klass.attrs.create!(name: 'last_name', type: 'Dynamic::Schema::Attribute::String')
    @association_klass = @klass.associations.create!(name: 'contact', type: 'Dynamic::Schema::Association::BelongsTo', target_klass: @klass, :schema => @schema)
    @schema.klasses.reload
    @schema.load
  end

  context 'create through an association' do
    before(:each) do
      @a = D::Earth::Person.create(last_name: 'A')
      expect(@a).to respond_to(:contact)
    end

    it 'should create a dynamic_association' do
      expect {
        @a.build_contact(last_name: 'B')
        @a.save
        @a.dynamic_associations.reload
      }.to change {
        @a.dynamic_associations.length
      }.by(1)
    end
  end

  context 'create through an association_id' do
    before(:each) do
      @a = D::Earth::Person.create(last_name: 'A')
      @b = D::Earth::Person.create(last_name: 'B')
      expect(@a).to respond_to(:contact_id)
    end

    it 'should create a dynamic_association' do
      expect {
        @a.update_attribute(:contact_id, @b.id)
        @a.dynamic_associations.reload
      }.to change {
        @a.dynamic_associations.length
      }.by(1)

      expect(@a.contact.try(:id)).to eq(@b.id)
    end
  end

  context 'create a DynamicAssociation' do
    before(:each) do
      @a = D::Earth::Person.create(last_name: 'A')
      @b = D::Earth::Person.create(last_name: 'B')
    end

    it 'should change dynamic_associations' do
      expect {
        D::Earth::DynamicAssociation.create!(association_owner: @a, association_target: @b, schema_association: @association_klass)
        @a.dynamic_associations.reload
      }.to change {
        @a.dynamic_associations.length
      }.by(1)
    end

    it 'should change association' do
      expect {
        c = D::Earth::DynamicAssociation.create!(association_owner: @a, association_target: @b, schema_association: @association_klass)
      }.to change {
        @a.contact.try(:id)
      }.to(@b.id)
    end

  end

end
 
