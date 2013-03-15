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
  end

  def overall_stats(month, vendor)
    KeywordStat.overall_stats(self.id, month, vendor)
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
    KeywordStat.top_keywords(self.id, month, vendor)
  end

  def two_line_data(month, number = 12)
    base_data = KeywordStat.where(account_group_id: self.id).where("period <= ?", month)

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
    {months: months, monthly_spendings: monthly_spendings, clicks: clicks, conversions: conversions, cpcs: cpcs, cpss: cpss }
  end

  def ad_group_data(month)
    base_data = KeywordStat.where(account_group_id: self.id, period: month)

    costs = base_data.select("ad_group_id as ad_group_id, sum(cost) as cost").group("ad_group_id").order("cost DESC").map{|x| [AdGroup.find(x.ad_group_id).name, x.cost]}

    clicks = base_data.select("ad_group_id as ad_group_id, sum(click) as click").group("ad_group_id").order("click DESC").map{|x| [AdGroup.find(x.ad_group_id).name, x.click]}


    conversions = base_data.select("ad_group_id as ad_group_id, sum(conversion) as conversion").group("ad_group_id").order("conversion DESC").where("conversion > 0").map{|x| [AdGroup.find(x.ad_group_id).name, x.conversion]}
    {costs: costs, clicks: clicks, conversions: conversions }
  end

  def ad_group_summary(month)
    base_data = KeywordStat.where(account_group_id: self.id, period: month)
    data = base_data.select("ad_group_id as ad_group_id, sum(click) as click, sum(impression) as impression, sum(cost) as cost, avg(position) as position, sum(conversion) as conversion").group("ad_group_id").order("click DESC").limit(15).map do |x|
      [AdGroup.find(x.ad_group_id).name,
        x.click,
        x.cost,
        x.cost.to_f/x.click.to_i,
        x.impression,
        x.click*100/x.impression.to_f,
        x.position,
        x.conversion,
        x.conversion.to_f*100/x.click.to_i,
        x.cost.to_f/x.conversion
      ]
    end

    total = array_add(data)
    total[3] = total[2].to_f/total[1].to_i rescue 0
    total[5] = total[1]*100/total[4].to_f rescue 0
    total[8] = total[7].to_f*100/total[1].to_i rescue 0
    total[9] = total[2].to_f/total[7] rescue 0
    total[10] = ""

    data.each{|x| x[-1] = "N/A" if x[-1].infinite? || x[-1].nan? }
    p good_cps = data.map{|x| x[-1]}.select{|x| x!="N/A"}
    p average_cps = good_cps.sort[good_cps.count/2]
    data.map{|x| x.push( recommend(x[-1], average_cps))}

    [data, total]
  end

  def array_add(array_of_arrays)
    n = array_of_arrays[0].try(:size) || 0
    (0..n-1).map do |index|
      array_of_arrays.map{|x| x[index] || 0}.inject(&:+)
    end
  end

  def array_percent(array_of_arrays)
    sum = array_add(array_of_arrays)
    n = array_of_arrays[0].try(:size) || 0
    (0..n-1).map do |index|
      array_of_arrays.map{|x| (x[index]*100.to_f / sum[index]) rescue 0}
    end
  end

  def history_data(month)
    base_data = KeywordStat.where(account_group_id: self.id)
    data = base_data.select("period as date, sum(cost) as cost").
      group("period").order("date ASC").map(&:cost)

  end

  def historical_records(month)
    data = two_line_data(month, 1000)
    {spendings: last_average_high_low(data[:monthly_spendings]),
     clicks: last_average_high_low(data[:clicks]),
     cpcs: last_average_high_low(data[:cpcs]),
     conversions: last_average_high_low(data[:conversions])
    }
  end

  def vendor_split(month)
    base_data = KeywordStat.where(account_group_id: self.id, period: month)

    data = base_data.select("vendor, sum(click) as click, sum(cost) as cost, sum(conversion) as conversion").group("vendor").order("vendor desc").map do |x|
        [x.vendor, x.click, x.cost, x.conversion]
    end
    [data, array_percent(data)]
  end

  def historical_annuals(month)
    base_data = KeywordStat.where(account_group_id: id).where("period <= ?", month)
    annuals = base_data.select("date_part('year',period) as year, count(distinct period) as periods, sum(cost) as cost, sum(click) as click, sum(impression) as impression, sum(conversion) as conversion").group("year").order("year desc").map do |x|
      {year: x.year, months: x.periods.to_i, impression: x.impression, click: x.click, cost: x.cost, conversion: x.conversion}
    end
    total = base_data.select("count(distinct period) as periods, sum(cost) as cost, sum(click) as click, sum(impression) as impression, sum(conversion) as conversion").map do |x|
      {months: x.periods.to_i, impression: x.impression, click: x.click, cost: x.cost, conversion: x.conversion}
    end
    [annuals, total[0]]
  end

  def last_average_high_low(data)
    [data[-1],
      data.sum.to_f/data.count,
      data.max,
      data.min
    ]
  end

  def content_targeting_data(month)
    DomainStat.content_targeting_data(self.id, month)
  end

  def ad_copy_performance_data(month)
    AdStat.ad_copy_performance_data(self.id, month)
  end

  def summary_data_over_time(month)
    KeywordStat.summary_data_over_time(self.id, month)
  end
  private

  def recommend real, benchmark
    if real == "N/A"
      "Decrease"
    elsif real > benchmark * 1.1
      "Decrease"
    elsif real < benchmark * 0.9
      "Increase"
    else
      "No change"
    end
  end
end
