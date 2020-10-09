require 'rails_helper'

RSpec.describe 'UserPages', type: :request do
  subject { page }

  describe 'signup' do
    before { visit signup_path }
    let(:submit) { 'Create my account' }

    describe 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe 'after submission' do
        before { click_button submit }
        it { should have_title('Sign up') }
        it { should have_content('error') }
      end
    end

    describe 'with valid information' do
      before do
        fill_in 'Name', with: 'Example User'
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Password', with: '123456'
        fill_in 'Confirm Password', with: '123456'
      end

      it 'should create a user' do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
    end

    it 'should signup' do
      expect(page).to have_selector('h1', text: 'Sign up')
      expect(page).to have_title('RoR Sample | Sign up')
    end
  end

  context 'profile page' do
    let(:user) { FactoryBot.create(:user) }
    let!(:m1) { FactoryBot.create(:micropost, user: user, content: 'Foo') }
    let!(:m2) { FactoryBot.create(:micropost, user: user, content: 'Bar') }

    before { visit user_path(user) }

    it { should have_selector('h1', text: user.name) }
    it { should have_title("RoR Sample | #{user.name}") }

    context 'microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end
  end

  context 'edit' do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe 'page' do
      it { should have_selector('h1', text: 'Update your profile') }
      it { should have_title('Edit user') }
      it { should have_link('change', href: 'https://www.gravatar.com/avatar') }
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }
      it { should have_content('error') }
    end

    describe 'with valid information' do
      let(:new_name) { 'New Name' }
      let(:new_email) { 'new@example.com' }
      before do
        fill_in 'Name',	with: new_name
        fill_in 'Email',	with: new_email
        fill_in 'Password',	with: user.password
        fill_in 'Confirm Password',	with: user.password
        click_button 'Save changes'
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  context 'index' do
    let(:user) { FactoryBot.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_selector('h1', text: 'All users') }

    context 'pagination' do
      it 'should list each user' do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    context 'delete links' do
      it { should_not have_link('delete') }

      context 'as an admin user' do
        let(:admin) { FactoryBot.create(:admin) }

        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it 'should be able to delete another user' do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(admin)) }
      end
    end
  end
end
