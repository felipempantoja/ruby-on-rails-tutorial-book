require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let(:base_title) { 'RoR Sample' }

  describe 'GET /static_pages/home' do
    before { visit root_path }

    context 'when a user arrives the root page and it gets rendered' do
      it { expect(page).to have_selector('h1', text: 'Welcome to the Sample App') }
      it { expect(page).to have_title(base_title) }
    end

    context 'for signed-in users' do
      let(:user) { FactoryBot.create(:user) }
      before do
        FactoryBot.create(:micropost, user: user, content: 'Lorem Ipsum')
        FactoryBot.create(:micropost, user: user, content: 'Dolor sit amet')
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
        end
      end
    end
  end

  describe 'GET /static_pages/help' do
    before { visit help_path }

    it 'should have "StaticPages#help" content' do
      expect(page).to have_content('StaticPages#help')
    end

    it 'should have the right title' do
      expect(page).to have_title("#{base_title} | Help")
    end
  end

  describe 'GET /static_pages/about' do
    before { visit about_path }

    it 'should have "StaticPages#about" content' do
      expect(page).to have_content('StaticPages#about')
    end

    it 'should have the right title' do
      expect(page).to have_title("#{base_title} | About")
    end
  end

  describe 'GET /static_pages/contact' do
    before { visit contact_path }

    it 'should have "StaticPages#contact" content' do
      expect(page).to have_content('StaticPages#contact')
    end

    it 'should have the right title' do
      expect(page).to have_title("#{base_title} | Contact")
    end
  end
end
