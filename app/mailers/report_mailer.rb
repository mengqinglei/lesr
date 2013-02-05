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
               render_to_string pdf: "results",
               template: "reports/show.pdf.erb",
               layout: "pdf.html.erb",
               lowquality: true,
               greyscale: true,
               no_background: true

             )
           end

    end
    account_group.update_attribute :last_emailed_at, Time.now
  end

end
