class GoogleAdDataImporter
  require 'csv'
  @queue = :report_queue
  def self.perform(upload_id)
    raw_file = Upload.find(upload_id)
    file = CSV.parse(raw_file.data, quote_char: "`", col_sep: "\t")#.unpack('C*').pack('U*')) #remove non UTF-8 char
    file.pop #Get rid of the total line at the end of file
      file.drop(6).each do |line|
        account, campaign, ad_group, google_ad_id,
          headline, line1, line2, display_url, destination_url,
          impression, click, _, _, cost, conversion, _, _ = line
        period = Upload.get_day(file.drop(4).take(1)[0].to_s)

        acc = Account.where(name: account, vendor: "Google").first_or_create
        cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
        ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

        ad = Ad.where(google_ad_id: google_ad_id).first_or_create do |b|
          b.headline = headline
          b.line1 = line1
          b.line2 = line2
          b.display_url = display_url
          b.google_ad_id = google_ad_id
          b.destination_url = destination_url
          b.ad_group_id = ad_grp.id
          b.campaign_id = cam.id
          b.account_id = acc.id
        end

        ad_stat = AdStat.where(period: period, ad_id: ad.id).first_or_create
        ad_stat.update_attributes({
            impression: impression.to_i + ad_stat.impression,
            click: click.to_i + ad_stat.click,
            cost: cost.to_f + ad_stat.cost,
            conversion: conversion.to_i + ad_stat.conversion,
            ad_group_id: ad_grp.id,
            campaign_id: cam.id, account_id: acc.id })
      end
      raw_file.destroy
  end
end
