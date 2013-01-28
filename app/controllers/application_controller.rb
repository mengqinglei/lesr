class ApplicationController < ActionController::Base
  if Rails.env.production?
    http_basic_authenticate_with :name => ENV['USERNAME'], :password => ENV['PASSWORD']
  end
  protect_from_forgery
  before_filter :set_date

  def set_date
    unless session["date"]
      today = Date.today
      p session["month"] = today.month == 1 ? 12 : today.month - 1
      p session["year"] = session["month"] == 12 ? today.year - 1 : today.year
      p session["month_in_word"] = Date::MONTHNAMES[session["month"]]
      p session["date"] = Date.new(session[:year], session["month"], 1)
    end
  end
end
