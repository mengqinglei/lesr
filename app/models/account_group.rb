class AccountGroup < ActiveRecord::Base
  attr_accessible :name, :conversion_type, :first_account, :separator, :agency_id, :google_account_ids, :bing_account_ids, :email_setting, :custom_email_text
  serialize :email_setting, Hash

  attr_accessor :first_account

  validates_presence_of :name, :first_account, on: :create

  has_many :accounts
  belongs_to :agency

  TYPES = ["Sale", "Lead", "Sign-up", "Download"]

  default_scope order("id ASC")

  def google_account_ids
    accounts.google.map(&:id)
  end

  def bing_account_ids
    accounts.bing.map(&:id)
  end

  def default_email_text
<<-EOS
Attached is your monthly report for October 2012. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

Les Reaves,
555.555.5555
EOS
  end
end
