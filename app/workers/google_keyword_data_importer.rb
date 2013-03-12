class GoogleKeywordDataImporter
  include Resque::Plugins::Status
  
  @queue = :report_queue

  def perform
    upload_id = options["upload_id"]
    raw_file = Upload.find(upload_id)
     file = CSV.parse(raw_file.data, quote_char: "`", col_sep: "\t")
     file.pop #Get rid of the total line at the end of file
     date_string = file.drop(4).take(1)[0].to_s
     period = Upload.get_day(date_string)
     total = file.size - 6
       file.drop(6).each_with_index do |line, index|
         at(index + 1, total, "At #{index + 1} of #{total}")
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
