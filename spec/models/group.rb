describe 'Group' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Group entity' do
    Group.entity_description.name.should == 'Group'
  end
end
