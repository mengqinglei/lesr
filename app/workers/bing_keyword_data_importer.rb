class BingKeywordDataImporter
  include Resque::Plugins::Status

  @queue = :report_queue

  def perform
    upload_id = options["upload_id"]
    raw_file = Upload.find(upload_id)
     file = CSV.parse(raw_file.data.gsub("\"",""), col_sep: "\t")
     file.pop.pop #Get rid of the last two line at the end of file
     date_string = file.drop(1).take(1).join.split(":")[1]
     period = Date.parse(date_string)


     headers = file.drop(9).take(1)[0]
     p headers
     p order = [headers.index("Account name"),
       headers.index("Campaign name"),
       headers.index("Ad group"),
       headers.index("Keyword"),
       headers.index("Impressions"),
       headers.index("Clicks"),
       headers.index("Conversions"),
       headers.index("Spend"),
       headers.index("Avg. position")
     ]
     total = file.size - 10
     file.drop(10).each_with_index do |line, index|
       at(index +1, total, "At #{index+1} of #{total}")
       account, campaign, ad_group, keyword,
         impression, click, conversion, cost, position = order.map{|x| line[x]}

       acc = Account.where(name: account, vendor: "Bing").first_or_create
       cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
       ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

       keyword_stat = KeywordStat.where(name: keyword, period: period, ad_group_id: ad_grp.id, vendor: 'Bing').first_or_create
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

