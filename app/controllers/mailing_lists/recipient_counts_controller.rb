# frozen_string_literal: true

#  Copyright (c) 2012-2021, Die Mitte Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class MailingLists::RecipientCountsController < ApplicationController

  before_action :authorize_action, only: [:show]

  def show
    respond_to do |format|
      format.json { render_json }
    end
  end

  private

  def render_json
    render json: {
      valid_recipient_count: valid_count,
      invalid_recipient_count: invalid_count
    }.to_json
  end

  private

  def valid_count
    @valid_count ||= true?(params[:households]) ?
      household_list.household_count :
      mailing_list.people_count(people_scope)
  end

  def invalid_count
    @invalid_count ||= mailing_list.people_count - valid_people_recipient_count
  end

  def valid_people_recipient_count
    if true?(params[:households])
      household_list.household_people.count + household_list.people_without_household.count
    else
      valid_count
    end
  end

  def authorize_action
    authorize!(:show_recipient_count, mailing_list)
  end

  def people_scope
    case params[:message_type]
    when 'Message::Letter' then Person.with_address
    when 'Message::TextMessage' then Person.with_mobile
    end
  end

  def household_list
    @household_list ||= People::HouseholdList.new(mailing_list.people(people_scope).pluck(:id))
  end

  def mailing_list
    @mailing_list ||= MailingList.find(params[:mailing_list_id])
  end
end
