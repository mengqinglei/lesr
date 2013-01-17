class ReportMailer < ActionMailer::Base
  default from: "from@example.com"

  def report_email(account_group, user_session)
    @account_group = account_group
    self.instance_variable_set(:@session, user_session)

    pdf = WickedPdf.new.pdf_from_string(
      render_to_string(:pdf => "file_name",
               :template => 'reports/show.pdf.erb',
               :disable_javascript => false,
               :layout  => 'pdf.html',
               :disable_smart_shrinking => true)
    )

    # pdf = WickedPdf.new.pdf_from_string(user_session.to_json)

    attachments['report.pdf'] = pdf if pdf.present?

    mail :to => "legendben@gmail.com",
         :cc => @account_group.email_setting[:cc],
         :bcc => @account_group.email_setting[:bcc],
         :subject => @account_group.email_setting[:subject]
  end
end
