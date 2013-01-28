require 'csv'
namespace :import do
  namespace :google do
    desc "import google ad stats"
    task :ad_stats, [:filename] => :environment do |t, args|
      file = CSV.parse(File.read(args.filename))#.unpack('C*').pack('U*')) #remove non UTF-8 char
      file.pop #Get rid of the total line at the end of file
      ActiveRecord::Base.transaction do
        file.drop(6).each do |line|
          account, campaign, ad_group, google_ad_id,
          headline, line1, line2, display_url, destination_url,
          impression, click, _, _, cost, conversion, _, _ = line
          period = file.drop(4).take(1)[0][1].split("-")[0].to_date

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
          ad_stat.update_attributes({ impression: impression, click: click,
            cost: cost, conversion: conversion, ad_group_id: ad_grp.id,
            campaign_id: cam.id, account_id: acc.id })
        end
      end
    end

    desc "import google domain stats"
    task :domain_stats, [:filename] => :environment do |t, args|
      puts "IMPORT DOMAIN STATS"

      file = CSV.parse(File.read(args.filename), quote_char: "|", col_sep: "\t")#.unpack('C*').pack('U*')) #remove non UTF-8 char
      file.pop #Get rid of the total line at the end of file
      ActiveRecord::Base.transaction do
        print "0"
        file.drop(6).each_with_index do |line, index|
          print "\r"
          print index+1
          account, domain, campaign, ad_group,
          impression, click,_, _, cost, conversion, _ = line
          p file.drop(4).take(1)
          period = file.drop(4).take(1)[0][1].split("-")[0].to_date

          acc = Account.where(name: account, vendor: "Google").first_or_create
          cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
          ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

          domain_stat = DomainStat.where(name: domain, period: period, ad_group_id: ad_grp.id).first_or_create
          domain_stat.update_attributes({ impression: impression, click: click,
            cost: cost, conversion: conversion,
            campaign_id: cam.id, account_id: acc.id })
        end
      end
    end

    desc "import google keyword stats"
    task :keyword_stats, [:filename] => :environment do |t, args|
      puts "IMPORT KEYWORDS STATS"
      file = File.read(args.filename) if args.filename #.force_encoding('utf-8').unpack('C*').pack('U*')
      file ||= args.data
      puts file
      break
      file = CSV.parse(file, quote_char: "|", col_sep: "\t")
      #file = CSV.read(args.filename, :quote_char => "|")
      file.pop #Get rid of the total line at the end of file
      date_string = file.drop(4).take(1)[0][1].split("-")[0]
      period = Date.parse(date_string)

      ActiveRecord::Base.transaction do
        file.drop(6).each do |line|
          account, campaign, keyword, ad_group,
          impression, click,_, _, cost, position, conversion, _, _ = line

          acc = Account.where(name: account, vendor: "Google").first_or_create
          cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
          ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

          keyword_stat = KeywordStat.where(name: keyword, period: period, ad_group_id: ad_grp.id, vendor: 'Google').first_or_create
          keyword_stat.update_attributes({ impression: impression.to_i, click: click.to_i,
            cost: cost.to_f, conversion: conversion.to_i,
            campaign_id: cam.id, account_id: acc.id, position: position.to_f })
        end
      end
    end
  end

  namespace :bing do
    desc "import bing ad stats"
    task :keyword_stats, [:filename] => :environment do |t, args|
      puts "IMPORT BING DATA"
      file = CSV.parse(File.read(args.filename).unpack('C*').pack('U*').gsub("\"", "")) #remove non UTF-8 char
      2.times { file.pop } #Get rid of invalid lines at the end of file
      ActiveRecord::Base.transaction do
        print "0"
        file.drop(10).each_with_index do |line, index|
          print "\r"
          print index+1
          account, campaign, ad_group, _, keyword, _,
          impression, click,_, cost, position, conversion, _, _ = line
          period = Date.parse(file.drop(1).take(1)[0][0].split(":")[1])

          acc = Account.where(name: account, vendor: "Bing").first_or_create
          cam = Campaign.where(name: campaign, account_id: acc.id).first_or_create
          ad_grp = AdGroup.where(name: ad_group, campaign_id: cam.id, account_id: acc.id).first_or_create

          keyword_stat = KeywordStat.where(name: keyword, period: period, ad_group_id: ad_grp.id, vendor: 'Bing').first_or_create
          keyword_stat.update_attributes({ impression: impression, click: click,
            cost: cost, conversion: conversion,
            campaign_id: cam.id, account_id: acc.id, position: position })
        end
      end
    end
  end

  desc "import all of the data"
  task :all => :environment do
    Rake::Task["import:google:domain_stats"].invoke('db/seeds/gcon.csv')

    Rake::Task["import:google:keyword_stats"].invoke('db/seeds/gall.csv')
  end

end
