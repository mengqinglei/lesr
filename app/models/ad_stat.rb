class AdStat < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :ad_group_id, :ad_id, :campaign_id, :click, :conversion, :cost, :impression, :period

  belongs_to :ad
  belongs_to :ad_group
  belongs_to :campaign
  belongs_to :account
  belongs_to :account_group

  def self.ad_copy_performance_data(account_group_id, month)
    ad_group_ids = where(account_group_id: account_group_id, period: month).order("ad_group_id ASC").select("ad_group_id").map(&:ad_group_id).uniq

    ad_group_ids.map do |x|
      ad_group = AdGroup.find(x)
      [ad_group.name,
       ad_group.ads.map do |y|
         [y, y.ad_stats.where(period: month).first]
        end
      ]
    end
  end
end
