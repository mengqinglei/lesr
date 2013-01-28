class ReportsController < ApplicationController
  def show
    @session = session
    @account_group = AccountGroup.find(params[:account_group_id])
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name",
               disable_javascript: false,
               layout: 'pdf.html',
               disable_smart_shrinking: true,
               :lowquality => true,
               :greyscale => true,
               :no_background => true
      end
    end
  end

  def set_month
    session["month"] = params[:month].to_i
    session["year"] = params[:year].to_i
    session["month_in_word"] = Date::MONTHNAMES[session["month"]]
    session["date"] = Date.new(session[:year], session["month"], 1)
    render json: {message: "Date range updated!"}, status: 200
  end

  def send_emails
    (params["account_groups"] || []).each do |id|
      Resque.enqueue(EmailReportWorker, [id, session])
    end
    flash[:success] = "Emails are being sent. Please check back in a couple minutes."
    redirect_to :back
  end
end
