# encoding: utf-8

#  Copyright (c) 2012-2016, Dachverband Schweizer Jugendparlamente. This file is part of
#  hitobito_dsj and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_dsj.

require 'spec_helper'

describe 'Person Tags', js: true do

  subject { page }
  let(:group) { groups(:top_group) }
  let(:leader) { Fabricate(Group::TopGroup::Leader.name.to_sym, group: group).person }
  let(:secretary) { Fabricate(Group::TopGroup::LocalSecretary.name.to_sym, group: group).person }
  let(:user) { leader }
  let(:person) { people(:top_leader) }

  before do
    sign_in(user)
  end

  context 'listing' do
    context 'user without :index_tags permission' do
      let(:user) { secretary }

      it 'does not show tags section' do
        expect(page).to have_no_content('Tags')
      end
    end

    context 'user with :index_tags permission' do
      let(:user) { leader }

      it 'lists tags without categories' do
        person.tags.create!(name: 'lorem')
        person.tags.create!(name: 'ipsum')
        visit group_person_path(group_id: group.id, id: person.id)

        expect(page).to have_content('Tags')
        expect(all('.person-tags-category').length).to eq(1)
        expect(page).to have_no_selector('.person-tags-category-title')
        expect(all('.person-tag')[0].text).to eq('ipsum')
        expect(all('.person-tag')[1].text).to eq('lorem')
      end

      it 'lists tags grouped by categories' do
        person.tags.create!(name: 'vegetable:potato')
        person.tags.create!(name: 'pizza')
        person.tags.create!(name: 'fruit:banana')
        person.tags.create!(name: 'fruit:apple')
        visit group_person_path(group_id: group.id, id: person.id)

        expect(page).to have_content('Tags')
        expect(all('.person-tags-category').length).to eq(3)
        expect(all('.person-tags-category-title').map(&:text)).to eq(%w(fruit vegetable Andere))
        expect(all('.person-tags-category')[0].all('.person-tag').map(&:text)).
          to eq(%w(apple banana))
        expect(all('.person-tags-category')[1].all('.person-tag').map(&:text)).
          to eq(%w(potato))
        expect(all('.person-tags-category')[2].all('.person-tag').map(&:text)).
          to eq(%w(pizza))
      end
    end
  end

  context 'creation' do
    before do
      user.tags.create!(name: 'pasta')
      visit group_person_path(group_id: group.id, id: person.id)
    end

    it 'adds newly created tags' do
      expect(page).to have_content('Tags')
      expect(page).to have_selector('.person-tag-add')
      expect(page).to have_no_selector('.person-tags-add-form')

      find('.person-tag-add').click
      expect(page).to have_no_selector('.person-tag-add')
      expect(page).to have_selector('.person-tags-add-form')

      within '.person-tags-add-form' do
        fill_in 'tag_name', :with => 'pizza'
      end
      find('.person-tags-add-form button').click
      expect(page).to have_selector('.person-tag', text: 'pizza')
      expect(person.tags.count).to eq(1)
      expect(person.tags.last.name).to eq('pizza')
      expect(page).to have_selector('.person-tag-add')
      expect(page).to have_no_selector('.person-tags-add-form')

      find('.person-tag-add').click
      within '.person-tags-add-form' do
        fill_in 'tag_name', :with => 'pas'
      end
      expect(page).to have_selector('ul.typeahead li a', text: 'pasta')
      find('ul.typeahead li a').click
      find('.person-tags-add-form button').click
      expect(page).to have_selector('.person-tag', text: 'pasta')
      expect(person.tags.count).to eq(2)
      expect(person.tags.last.name).to eq('pasta')

      find('.person-tag-add').click
      within '.person-tags-add-form' do
        fill_in 'tag_name', :with => 'fruit:banana'
      end
      find('.person-tags-add-form button').click
      expect(page).to have_selector('.person-tags-category', count: 2)
      expect(all('.person-tags-category-title').map(&:text)).to eq(%w(fruit Andere))
      expect(all('.person-tags-category')[0].all('.person-tag').map(&:text)).
        to eq(%w(banana))
      expect(all('.person-tags-category')[1].all('.person-tag').map(&:text)).
        to eq(%w(pasta pizza))
      expect(person.tags.count).to eq(3)
      expect(person.tags.last.name).to eq('fruit:banana')
    end
  end

  context 'deletion' do
    before do
      person.tags.create!(name: 'pizza')
      person.tags.create!(name: 'fruit:banana')
      person.tags.create!(name: 'fruit:apple')
      visit group_person_path(group_id: group.id, id: person.id)
    end

    it 'removes deleted tags' do
      expect(page).to have_selector('.person-tags-category', count: 2)
      expect(page).to have_selector('.person-tag-remove', count: 3)

      find('.person-tag', text: 'apple').find('.person-tag-remove').click
      expect(page).to have_selector('.person-tags-category', count: 2)
      expect(all('.person-tags-category')[0].all('.person-tag').map(&:text)).
        to eq(%w(banana))

      find('.person-tag', text: 'banana').find('.person-tag-remove').click
      expect(page).to have_selector('.person-tags-category', count: 1)
      expect(all('.person-tags-category')[0].all('.person-tag').map(&:text)).
        to eq(%w(pizza))
    end
  end

end
