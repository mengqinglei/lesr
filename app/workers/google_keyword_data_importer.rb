class GoogleKeywordDataImporter
  @queue = :report_queue
  def self.perform(upload_id)
     raw_file = Upload.find(upload_id)
     file = CSV.parse(raw_file.data, quote_char: "|", col_sep: "\t")
     file.pop #Get rid of the total line at the end of file
     date_string = file.drop(4).take(1)[0][1..3].join.split("-")[0]
     period = Date.parse(date_string)

     ActiveRecord::Base.transaction do
       file.drop(6).each do |line|
         account, campaign, keyword, ad_group,
           impression, click,_, _, cost, position, conversion, _, _ = line

         acc = Account.where(name: account, vendor: "Google").first_or_create
         cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
         ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

         keyword_stat = KeywordStat.where(name: keyword, period: period, ad_group_id: ad_grp.id, vendor: 'Google').first_or_create
         keyword_stat.update_attributes({
           impression: impression.to_i + keyword_stat.impression,
           click: click.to_i + keyword_stat.click,
           cost: cost.to_f + keyword_stat.cost,
           conversion: conversion.to_i + keyword_stat.conversion,
           campaign_id: cam.id, account_id: acc.id, position: position.to_f })
       end
       raw_file.destroy
     end

  end
end
