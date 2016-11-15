# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# == Schema Information
#
# Table name: subscriptions
#
#  id              :integer          not null, primary key
#  mailing_list_id :integer          not null
#  subscriber_id   :integer          not null
#  subscriber_type :string           not null
#  excluded        :boolean          default(FALSE), not null
#

class Subscription < ActiveRecord::Base

  include RelatedRoleType::Assigners

  acts_as_taggable


  ### ASSOCIATIONS

  belongs_to :mailing_list

  belongs_to :subscriber, polymorphic: true

  has_many :related_role_types, as: :relation, dependent: :destroy


  ### VALIDATIONS

  validates_by_schema
  validates :related_role_types, presence: { if: ->(s) { s.subscriber.is_a?(Group) } }

  validates :subscriber_id, uniqueness: { unless: ->(s) { s.subscriber.is_a?(Group) },
                                          scope: [:mailing_list_id, :subscriber_type, :excluded] }
  validates :subscriber_id, inclusion: { if: ->(s) { s.subscriber.is_a?(Group) },
                                         in: ->(s) { s.possible_groups.pluck(:id) },
                                         message: :group_not_allowed }
  validates :subscriber_id, inclusion: { if: ->(s) { s.subscriber.is_a?(Event) },
                                         in: ->(s) { s.possible_events.pluck(:id) },
                                         message: :event_not_allowed }

  ### INSTANCE METHODS

  def to_s(format = :default)
    if subscriber.is_a?(Group)
      subscriber.with_layer.join(' / ')
    else
      subscriber.to_s(format).dup
    end
  end

  def possible_events
    Event.
      joins(:groups, :dates).
      where('event_dates.start_at >= ?', earliest_possible_event_date).
      where(groups: { id: possible_event_groups })
  end

  def possible_groups
    mailing_list.group.self_and_descendants
  end

  def grouped_role_types
    related_role_types.each_with_object({}) do |related_role_type, result|
      result[related_role_type.group_class] ||= []
      result[related_role_type.group_class] << related_role_type.role_class
    end
  end

  private

  def earliest_possible_event_date
    Time.zone.now.prev_year.beginning_of_year
  end

  # this may be different from possible_groups in wagons
  def possible_event_groups
    mailing_list.group.self_and_descendants
  end

end
