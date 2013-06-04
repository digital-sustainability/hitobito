# encoding: utf-8

class FullTextController < ApplicationController

  skip_authorization_check

  helper_method :entries

  respond_to :html

  def index
    @people = if params[:q].to_s.size >= 2
      PersonDecorator.decorate(list_people)
    else
      Kaminari.paginate_array([]).page(1)
    end
    respond_with(@people)
  end

  def query
    people = query_people.collect{|i| PersonDecorator.new(i).as_quicksearch }
    groups = query_groups.collect{|i| GroupDecorator.new(i).as_quicksearch }

    result = if people.present? && groups.present?
      people + [{label: '—' * 20}] + groups
    else
      people + groups
    end
    render json: result
  end

  private

  def list_people
    entries = Person.search(params[:q],
                            page: params[:page],
                            order: 'last_name asc, first_name asc, @relevance desc',
                            with: {sphinx_internal_id: accessible_people_ids})
    entries = Person::PreloadGroups.for(entries)
    entries = Person::PreloadPublicAccounts.for(entries)
    entries
  end

  def query_people
    Person.search(params[:q],
                  per_page: 10,
                  with: {sphinx_internal_id: accessible_people_ids})
  end

  def query_groups
    Group.search(params[:q],
                 per_page: 10,
                 include: :parent)
  end

  def accessible_people_ids
    Rails.cache.fetch("accessible_people_ids_for_#{current_user.id}", expires_in: 15.minutes) do
      load_accessible_people_ids
    end
  end

  def load_accessible_people_ids
    accessible = Person.accessible_by(PersonAccessibles.new(current_user))

    # This still selects all people attributes :(
    # accessible.pluck('people.id')

    # rewrite query to only include id column
    sql = accessible.to_sql.gsub(/SELECT (.+) FROM /, 'SELECT DISTINCT people.id FROM ')
    result = Person.connection.execute(sql)
    result.collect {|row| row[0] }
  end

  def entries
    @people
  end
end