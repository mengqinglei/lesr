class ReportsController < ApplicationController
  def show
    @account_group = AccountGroup.find(params[:account_group_id])
  end

  def set_month
    session[:month] = params[:month].to_i
    session[:year] = params[:year].to_i
    session[:month_in_word] = Date::MONTHNAMES[session[:month]]
    render json: {message: "Date range updated!"}, status: 200
  end
end
