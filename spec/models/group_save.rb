describe 'GroupSave' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a GroupSave entity' do
    GroupSave.entity_description.name.should == 'GroupSave'
  end
end
