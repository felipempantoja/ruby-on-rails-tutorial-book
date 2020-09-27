require 'rails_helper'

RSpec.describe 'AuthenticationPages', type: :request do
  subject { page }

  describe 'signin page' do
    before { visit signin_path }

    it { should have_selector('h1', text: 'Sign in') }
    it { should have_title('Sign in') }

    describe 'with valid information' do
      let(:user) { FactoryBot.create(:user) }
      before do
        User.create(user.attributes)
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Sign in'
      end

      it { should have_title(user.name) }

      it { should have_link('Users', href: users_path) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }

      it { should_not have_link('Sign in', href: signin_path) }

      describe 'followed by signout' do
        before { click_link 'Sign out' }
        it { should have_link('Sign in', href: signin_path) }
      end
    end

    describe 'with invalid information' do
      before { click_button 'Sign in' }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }

      describe 'after visiting another page' do
        before { click_link 'Home' }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end
  end

  context 'authorization' do
    context 'for non-signed-in users' do
      let(:user) { FactoryBot.create(:user) }

      context 'when visiting the edit page' do
        before { visit edit_user_path(user) }
        it { should have_title('Sign in') }
      end

      context 'when submiting to the update action' do
        before { put user_path(user) }
        specify { response.should redirect_to signin_path }
      end

      context 'when attempting to visit a protected page' do
        before do
          visit edit_user_path(user)
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end

        context 'after signing in' do
          it 'should render the desired protected page' do
            page.should have_title('Edit user')
          end
        end
      end

      context 'in the Users controller' do
        context 'visiting the user index' do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end
    end

    context 'as wrong user' do
      let(:user) { FactoryBot.create(:user) }
      let(:wrong_user) { FactoryBot.create(:user, id: 10, email: 'wrong@example.com') }
      before { sign_in user }

      context 'visiting user edit page' do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      # context 'submitting a PUT request to the Users#update action' do
      #   before { put user_path(wrong_user), params: { user: wrong_user.to_json } }
      #   specify { response.should redirect_to root_path }
      # end
    end

    context 'as non-admin user' do
      let(:user) { FactoryBot.create(:user) }
      let(:non_admin) { FactoryBot.create(:user) }

      before { sign_in non_admin }

      describe 'submitting a DELETE request to the Users#destroy action' do
        before { delete user_path(user) }
        specify { response.should redirect_to root_path }
      end
    end
  end
end
