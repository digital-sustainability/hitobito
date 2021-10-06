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

  def valid_count
    message.valid_recipient_count(households: true?(params[:households]))
  end

  def invalid_count
    message.invalid_recipient_count(households: true?(params[:households]))
  end

  def authorize_action
    authorize!(:show_recipient_count, message)
  end

  def message
    Message.new(type: params[:message_type], mailing_list_id: params[:mailing_list_id])
  end
end
