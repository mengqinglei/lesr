class ApplicationController < ActionController::Base
  if Rails.env.production?
    http_basic_authenticate_with :name => ENV['USERNAME'], :password => ENV['PASSWORD']
  end
  protect_from_forgery
  before_filter :set_date

  def set_date
    unless session["date"]
      today = Date.today
      latest_date = KeywordStat.order("period desc").first.period || Date.new(2012,12,1)
       session["month"] = latest_date.month
       session["year"] = latest_date.year
       session["month_in_word"] = Date::MONTHNAMES[session["month"]]
       session["date"] = latest_date
    end
  end
end
