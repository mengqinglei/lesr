class ReportMailer < ActionMailer::Base
  default from: "lesr@smartsem.com"

  def report_email(account_group, user_session)
    @account_group = account_group

    self.instance_variable_set(:@session, user_session) # enable mail() method could render the collect views
    self.instance_variable_set(:@lookup_context, nil) # enable mail() method could render the collect views
    mail(:to => @account_group.email_setting[:to],
         :cc => @account_group.email_setting[:cc],
         :bcc => @account_group.email_setting[:bcc],
         :subject => @account_group.email_setting[:subject],
         :template_path => 'report_mailer',
         :template_name => 'report_email.text.erb') do |format|
           format.text
           format.pdf do
             attachments['report.pdf'] = WickedPdf.new.pdf_from_string(
               render_to_string(pdf: "results",
               template: "reports/show.pdf.erb",
               layout: "pdf.html.erb"),
               lowquality: true,
               greyscale: true,
               no_background: true,
               disable_javascript: false,
               layout: 'pdf.html',
               :lowquality => true,
               :margin => {:top                => 15,
                           :bottom             => 15,
                           :left               => 10,
                           :right              => 10},
               :header => {:left => @account_group.name,
                           :right => "#{user_session['month_in_word']} #{user_session['year']}",
                           :margin => {left: 30},
                           :spacing => 5,
                           :font_size => 9
                          },
               :footer => {:left => @account_group.agency.try(:name),
                           :right => "Page [page] of [topage]",
                           :margin => {left: 30},
                           :spacing => 5,
                           :font_size => 9
                          }

             )
           end

    end
    account_group.update_attribute :last_emailed_at, Time.now
  end

end
