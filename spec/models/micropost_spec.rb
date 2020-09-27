require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user) { FactoryBot.create(:user) }
  before { @micropost = user.microposts.build(content: 'Lorem Ipsum') }
  # before do
  #   # this code is wrong!
  #   @micropost = Micropost.new(content: 'Lorem Ipsum', user_id: user.id)
  # end

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  # it { user.should == user }

  it { should be_valid }

  context 'when user_id is not present' do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  context 'with blank content' do
    before { @micropost.content = ' ' }
    it { should_not be_valid }
  end

  context 'with content that is too long' do
    before { @micropost.content = 'a' * 141 }
    it { should_not be_valid }
  end

  # context "describe attributes" do
  #   it 'should not allow access to user_id' do
  #     expect do
  #       Micropost.new(user_id: user.id)
  #     end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
  #   end
  # end
end
