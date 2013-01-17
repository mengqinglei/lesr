class Ad < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :ad_group_id, :campaign_id, :destination_url, :display_url, :google_ad_id, :headline, :line1, :line2

  has_many :ad_stats

  belongs_to :ad_group
end
