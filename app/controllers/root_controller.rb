class RootController < ApplicationController
  before_filter :api_client

  def index
    @resource = '4swk-wcg8'
    @query = build_query
    @response = @client.get(@resource, @query)

    respond_to do |format|
      format.html
      format.json { render json: average }
    end
  end

  private

  def average
    sum = 0

    @response.each do |item|
      sum += item.total_earnings.to_f
    end

    average = sum / @response.count
    average.round(2)
  end

  def build_query
    { "$where" => "title='#{params[:title]}'" }
  end
end
