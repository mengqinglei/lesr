class EmailReportWorker
  @queue = :report_queue
  def self.perform(data)
    ReportMailer.report_email(AccountGroup.find(data[0]),data[1]).deliver!
  end
end
