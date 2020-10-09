require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.create(name: 'Example User', email: 'user@example.com',
                        password: 'foobar', password_confirmation: 'foobar')
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }

  it { should be_valid }
  it { should_not be_admin }

  context 'when name is not present' do
    before { @user.name = ' ' }
    it { should_not be_valid }
  end

  context 'when email is not present' do
    before { @user.email = ' ' }
    it { should_not be_valid }
  end

  context 'when name is too short' do
    before { @user.name = 'Mu' }
    it { should_not be_valid }
  end

  context 'when name is too long' do
    before { @user.name = 'A' * 51 }
    it { should_not be_valid }
  end

  context 'when email format is invalid' do
    it 'should be invalid' do
      addresses = %w[user@foo,com user_at_foo.org foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end
    end
  end

  context 'when email format is valid' do
    it 'should be valid' do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end
    end
  end

  context 'when email address is already taken' do
    let(:user_with_same_email) do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it { user_with_same_email.should be false }
  end

  context 'email addres with mixed case' do
    let(:mixed_case) { 'Foo@exAmple.com.BR' }
    it 'should be saved as all lower-case' do
      @user.email = mixed_case
      @user.save
      @user.reload.email.should == mixed_case.downcase
    end
  end

  context 'when password is not present' do
    before { @user.password = @user.password_confirmation = ' ' }
    it { should_not be_valid }
  end

  context 'when password doesn\'t match confirmation' do
    before { @user.password_confirmation = 'mismatch' }
    it { should_not be_valid }
  end

  context 'when password confirmation is nil' do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  context %(with a password that's too short) do
    before { @user.password = @user.password_confirmation = 'a' * 5 }
    it { should be_invalid }
  end

  context 'return value of authenticate method' do
    before { @user.save }
    # as let memoizes its value, this db retrieval will just occur once (like cache?)
    let(:found_user) { User.find_by_email(@user.email) }

    context 'when valid password' do
      it { should == found_user.authenticate(@user.password) }
    end

    context 'when invalid password' do
      let(:user_for_invalid_password) { found_user.authenticate('invalid') }
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be false }
    end
  end

  context 'remember token' do
    before { @user.save }
    it { @user.remember_token.should_not be_blank }
  end

  context 'with admin attribute set to true' do
    before { @user.toggle!(:admin) }
    it { should be_admin }
  end

  context 'micropost associations' do
    before { @user.save }
    let!(:older_micropost) { FactoryBot.create(:micropost, user: @user, created_at: 1.day.ago) }
    let!(:newer_micropost) { FactoryBot.create(:micropost, user: @user, created_at: 1.hour.ago) }

    it 'should have the right microposts in the right order' do
      # newest first
      @user.microposts.should == [newer_micropost, older_micropost]
    end

    it 'should destroy associated microposts' do
      microposts = @user.microposts
      @user.destroy
      microposts.each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    # context 'status' do
    #   let(:unfollowed_post) do
    #     FactoryBot.create(:micropost, user:FactoryBot.create(:user))
    #   end
    #   it { expect(subject.feed).to include(newer_micropost) }
    #   it { expect(subject.feed).to include(older_micropost) }
    #   it { expect(subject.feed).to include(unfollowed_post) }
    # end
  end
end
