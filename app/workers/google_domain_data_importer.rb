class GoogleDomainDataImporter
  @queue = :report_queue
  def self.perform(upload_id)
      raw_file = Upload.find(upload_id)
      file = CSV.parse(raw_file.data, quote_char: "|", col_sep: "\t")#.unpack('C*').pack('U*')) #remove non UTF-8 char
      file.pop #Get rid of the total line at the end of file
      ActiveRecord::Base.transaction do
        print "0"
        file.drop(6).each_with_index do |line, index|
          account, domain, campaign, ad_group,
          impression, click,_, _, cost, conversion, _ = line
          period = file.drop(4).take(1)[0][1].split("-")[0].to_date

          acc = Account.where(name: account, vendor: "Google").first_or_create
          cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
          ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

          domain_stat = eval(raw_file.upload_type).where(name: domain, period: period, ad_group_id: ad_grp.id).first_or_create
          domain_stat.update_attributes({
            impression: impression.to_i + domain_stat.impression,
            click: click.to_i + domain_stat.click,
            cost: cost.to_f + domain_stat.cost,
            conversion: conversion.to_i + domain_stat.conversion,
            campaign_id: cam.id, account_id: acc.id })
        end
        raw_file.update_attribute :processed_at, Time.now
      end

  end
end

