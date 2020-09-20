require 'rails_helper'

RSpec.describe 'UserPages', type: :request do
  subject { page }

  describe 'GET /user_pages' do
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
        fill_in 'Confirmation', with: '123456'
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
    before { visit user_path(user) }

    it { should have_selector('h1', text: user.name) }
    it { should have_title("RoR Sample | #{user.name}") }
  end
end
