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
               :lowquality => true,
               :margin => {:top                => 15,
                           :bottom             => 15,
                           :left               => 10,
                           :right              => 10},
               :header => {:left => @account_group.name,
                           :right => "#{session[:month_in_word]} #{session[:year]}",
                           :margin => {left: 30},
                           :spacing => 5,
                           :font_size => 9
                          },
               :footer => {:html => { :template => 'reports/footer.pdf.erb',
                                      :locals   => { :agency => @account_group.agency }},
                           :right => "Page [page] of [topage]",
                           :margin => {left: 30},
                           :spacing => 5,
                           :font_size => 9
                          }
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
