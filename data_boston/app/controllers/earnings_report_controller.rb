class EarningsReportController < ApplicationController
  require 'github/markup'

  before_filter :api_client
  before_filter :set_year
  before_filter :set_resource
  before_filter :set_title

  def index
    @markdown = GitHub::Markup.render(MARKDOWN_FILE_PATH, File.read(MARKDOWN_FILE_PATH))
    @markdown = @markdown.html_safe
  end

  def show
    @results = @client.get(@resource, select_all_query)

    render :total_earnings
  end

  def total_earnings
    @results = @client.get(@resource, total_earnings_query)
    @average = @client.get(@resource, average_total_earnings_query).first.avg_total_earnings.to_f.round(2)

    respond_to do |format|
      format.html
      format.json { render json: @average }
    end
  end

  private

  def api_client
    @client = SODA::Client.new({
      domain: SODA_DOMAIN,
      app_token: SODA_API_TOKEN
    })
  end

  def set_year
    # set default
    @year = EARNINGS_REPORT_YEARS.last
    # override default if valid year is provided
    @year = params[:year].to_i if params[:year].present? && EARNINGS_REPORT_YEARS.include?(params[:year].to_i)
  end

  def set_resource
    # set default
    @resource = EARNINGS_REPORT_RESOURCES.last
    # get index for provided year
    index = EARNINGS_REPORT_YEARS.index(@year)
    # override default if valid year provided
    @resource = EARNINGS_REPORT_RESOURCES[index] if index.present?
  end

  def set_title
    @title = params[:title]
  end

  def select_all_query
    { "$select" => "*" }
  end

  def total_earnings_query
    { "$where" => "title like '%#{@title}%'" }
  end

  def average_total_earnings_query
    { "$select" => "avg(total_earnings)" }.merge(total_earnings_query)
  end
end
