class AccountGroup < ActiveRecord::Base
  attr_accessible :name, :conversion_type, :first_account, :separator, :agency_id, :google_account_ids, :bing_account_ids, :email_setting, :custom_email_text
  serialize :email_setting, Hash

  attr_accessor :first_account

  validates_presence_of :name, :first_account, on: :create

  has_many :accounts
  has_many :campaigns
  has_many :ad_groups
  has_many :domain_stats
  has_many :keyword_stats
  has_many :ad_stats

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

  def overall_stats(month, vendor)
    month = Date.parse(month) if month.is_a? String
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:click)
    s = self.keyword_stats.where(period: month, vendor: vendor).sum(:conversion)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)
    cpc = c.to_f/v
    cps = c.to_f/s

    last_month = month - 1.month
    lv = self.keyword_stats.where(period: last_month, vendor: vendor).sum(:click)
    ls = self.keyword_stats.where(period: last_month, vendor: vendor).sum(:conversion)
    lc =self.keyword_stats.where(period: last_month, vendor: vendor).sum(:cost)
    lcpc = lv == 0 ? 0 : lc.to_f/lv
    lcps = lv ==0 ? 0 : lc.to_f/ls

    {v: [v,lv,compare(v,lv)],
     s: [s,ls,compare(s,ls)],
     c: [c,lc,compare(c,lc)],
     cpc: [cpc,lcpc,compare(cpc,lcpc)],
     cps: [cps,lcps,compare(cps,lcps)]}
  end

  def top_traffic_stats(month, vendor)
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:click)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)

    KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).
      select("name, sum(click) as click, sum(cost) as cost, avg(position) as position").
      group("name").order("click DESC").limit(4).map do |x|
        [x.name, x.click, (100* x.click/v).to_i, x.cost, (100 * x.cost/c).to_i, x.position.to_i]
    end
  end

  def top_sales_stats(month, vendor)
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:conversion)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)

    KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).where("conversion > 0").
      select("name, sum(conversion) as conversion, sum(cost) as cost, avg(position) as position").
      group("name").order("conversion DESC").limit(4).map do |x|
        if x.conversion == 0 and v == 0
          percent = 0
          cps = 0
        end
        [x.name,
         x.conversion,
         percent || (100* x.conversion/v).to_i,
         cps || x.cost.to_f/x.conversion,
         x.position.to_i]
    end
  end

  def best_cps_stats(month, vendor)
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:conversion)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)

    KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).where("conversion > 0").
      select("name, (sum(cost)/sum(conversion)) as cps, sum(conversion) as conversion, sum(cost) as cost, avg(position) as position").
      group("name").order("cps ASC").limit(4).map do |x|
        percent = 0 if v == 0
        [x.name,
         x.conversion,
         percent || (100* x.conversion/v).to_i,
         x.cps,
         x.position.to_i]
    end
  end

  def worst_cps_stats(month, vendor)
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:conversion)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)

    KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).where("conversion > 0").select("name, (sum(cost)/sum(conversion)) as cps, sum(conversion) as conversion, sum(cost) as cost, avg(position) as position").
      group("name").order("cps DESC").limit(4).map do |x|
        percent = 0 if v == 0
        [x.name,
         x.conversion,
         percent || (100* x.conversion/v).to_i,
         x.cost,
         (100 * x.cost/c).to_i,
         x.cps]
    end
  end

  def best_cpc_stats(month, vendor)
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:click)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)

    KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).where("click > 0").
      select("name, (sum(cost)/sum(click)) as cpc, sum(click) as click, sum(cost) as cost, avg(position) as position").
      group("name").order("cpc ASC").limit(4).map do |x|
        percent = 0 if v == 0
        [x.name,
         x.click,
         percent || (100* x.click/v).to_i,
         x.cpc,
         x.position.to_i]
    end

  end

  def worst_cpc_stats(month, vendor)
    v = self.keyword_stats.where(period: month, vendor: vendor).sum(:click)
    c =self.keyword_stats.where(period: month, vendor: vendor).sum(:cost)

    KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).where("click > 0").select("name, (sum(cost)/sum(click)) as cpc, sum(click) as click, sum(cost) as cost, avg(position) as position").
      group("name").order("cpc DESC").limit(4).map do |x|
        percent = 0 if v == 0
        [x.name,
         x.click,
         percent || (100* x.click/v).to_i,
         x.cost,
         (100 * x.cost/c).to_i,
         x.cpc]
    end
  end

  def top_keywords(month, vendor)
    lines = KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).select("name, sum(conversion) as conversion, sum(impression) as impression, sum(click) as click, sum(cost) as cost, avg(position) as position").group("name").order("impression DESC").limit(47).map do |x|
      cpc = 0 if x.click == 0
      cps = 0 if x.conversion == 0
      [x.name, x.click, x.impression, (100 * x.click.to_f/x.impression).round(2), cpc || x.cost.to_f/x.click,x.cost,x.position, x.conversion, cps || x.cost.to_f/x.conversion]
    end
    sum = KeywordStat.where(account_group_id: self.id, period: month, vendor: vendor).select("sum(conversion) as conversion, sum(impression) as impression, sum(click) as click, sum(cost) as cost, avg(position) as position").first
    cpc = 0 if sum.click == 0
    cps = 0 if sum.conversion ==0
    y = [sum.click, sum.impression, (100* sum.click.to_f/sum.impression).round(2),
      cpc|| sum.cost/sum.click, sum.cost, sum.position.round(2), sum.conversion,
      cps || sum.cost/sum.conversion]
    [lines, y]

  end

  def two_line_data(month, number = 12)
    base_data = DomainStat.where(account_group_id: self.id, period: month)

    months = base_data.select("period as date").group("period").order("date").limit(number).map(&:date).map{|x| Date.parse(x).strftime("%b %y")}

    monthly_spendings = base_data.select("period as date, sum(cost) as cost").
      group("period").order("date ASC").limit(number).map(&:cost)

    clicks = base_data.select("period as date, sum(click) as click").
      group("period").order("date ASC").limit(number).map(&:click)
    cpcs= base_data.select("period as date, sum(click) as click, sum(cost) as cost").
      group("period").order("date ASC").limit(number).map do |x|
      x.cost/x.click
    end
    conversions = base_data.select("period as date, sum(conversion) as conversion").
      group("period").order("date ASC").limit(number).map(&:conversion)
    cpss= base_data.select("period as date, sum(conversion) as conversion, sum(cost) as cost").
      group("period").order("date ASC").limit(number).map do |x|
      x.cost/x.conversion
    end
    {months: months, monthly_spendings: monthly_spendings, clicks: clicks, conversions: conversions, cpcs: cpcs, cpss: cpss}
  end

  def ad_group_data(month)
    base_data = DomainStat.where(account_group_id: self.id, period: month)

    costs = base_data.select("ad_group_id as ad_group_id, sum(cost) as cost").group("ad_group_id").order("cost DESC").map{|x| [AdGroup.find(x.ad_group_id).name, x.cost]}

    clicks = base_data.select("ad_group_id as ad_group_id, sum(click) as click").group("ad_group_id").order("click DESC").map{|x| [AdGroup.find(x.ad_group_id).name, x.click]}


    conversions = base_data.select("ad_group_id as ad_group_id, sum(conversion) as conversion").group("ad_group_id").order("conversion DESC").where("conversion > 0").map{|x| [AdGroup.find(x.ad_group_id).name, x.conversion]}
    {costs: costs, clicks: clicks, conversions: conversions }
  end

  def history_data(month)
    base_data = KeywordStat.where(account_group_id: self.id)
    data = base_data.select("period as date, sum(cost) as cost").
      group("period").order("date ASC").map(&:cost)

  end

  private

  def compare(a, b)
    result = (100 * a/b - 100).to_i
    if result > 5
      "#{result}% higher than"
    elsif result < - 5
      "#{-result}% lower than"
    else
      "Almost the same as"
    end
  rescue
    ""
  end
end
