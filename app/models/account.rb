class Account < ActiveRecord::Base
  attr_accessible :name, :vendor

  belongs_to :account_group

  scope :google, where(vendor: "Google")
  scope :bing, where(vendor: "Bing")
  scope :unlinked, where(account_group_id: nil).google

  def self.for_group_select(account_group, vendor)
    where(account_group_id: [nil, account_group.id]).where(vendor: vendor).order("id ASC").collect{|x| [x.name, x.id]}
  end
end
