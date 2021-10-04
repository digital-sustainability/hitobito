# frozen_string_literal: true

#  Copyright (c) 2012-2021, CVP Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Messages::RecipientCountsController do
  let(:top_leader) { people(:top_leader) }
  let(:bottom_member) { people(:bottom_member) }

  before { sign_in(top_leader) }

  context 'GET index' do
    context 'without households' do
      let(:message) { messages(:letter) }

      before do
        20.times do
          fabricate_valid_person_recipient
        end

        10.times do
          fabricate_invalid_person_recipient
        end
      end

      it 'returns count' do
        get :show, params: { message_id: message.id, households: false, format: :json }

        expect(response_data[:valid_recipient_count]).to eq(20)
        expect(response_data[:invalid_recipient_count]).to eq(10)
      end
    end

    context 'with households' do
      let(:message) { messages(:letter) }

      before do
        5.times do
          fabricate_valid_person_recipient
        end

        10.times do
          fabricate_valid_households_recipient
        end

        10.times do
          fabricate_invalid_person_recipient
        end
      end

      it 'returns count' do
        get :show, params: { message_id: message.id, households: true, format: :json }

        expect(response_data[:valid_recipient_count]).to eq(15)
        expect(response_data[:invalid_recipient_count]).to eq(10)
      end
    end
  end

  private

  def response_data
    JSON.parse(response.body, symbolize_names: true)
  end

  def fabricate_invalid_person_recipient
    Fabricate(:subscription, mailing_list: message.mailing_list)
  end

  def fabricate_valid_person_recipient
    Fabricate(:subscription_with_subscriber_with_address, mailing_list: message.mailing_list)
  end

  def fabricate_valid_households_recipient
    housemate1 = fabricate_valid_person_recipient.subscriber
    housemate2 = fabricate_valid_person_recipient.subscriber
    
    fake_ability = instance_double('aby', cannot?: true)
    household1 = Person::Household.new(housemate1, fake_ability, housemate2, top_leader)
    household1.save
    household1.assign
    housemate2.update!(household_key: housemate1.household_key)
  end
end
