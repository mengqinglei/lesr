class AccountGroupsController < ApplicationController
  def index
    @account_groups = AccountGroup.all
  end

  def create
    @account_group = AccountGroup.new(params[:account_group])
    if @account_group.save
      @account = Account.find(params["account_group"]["first_account"])
      @account.account_group = @account_group
      @account.save
      flash[:success] = "Account group is successfully created"
      redirect_to :back
    else
      flash[:error] = @account_group.errors.full_messages
      redirect_to :back
    end
  end

  def email_modal
    @account_group = AccountGroup.find(params[:account_group_id])
    render layout: false
  end

  def account_modal
    @account_group = AccountGroup.find(params[:account_group_id])
    render layout: false
  end

  def update
    google_account_ids = params[:account_group].delete(:google_account_ids)
    google_account_ids.reject!(&:empty?)
    bing_account_ids = params[:account_group].delete(:bing_account_ids)
    bing_account_ids.reject!(&:empty?)
    all_account_ids = google_account_ids + bing_account_ids

    if google_account_ids.empty?
      flash[:error] = "You must have at least one Google account associated"
      redirect_to :back
    else
      @account_group = AccountGroup.find(params[:id])
      if @account_group.update_attributes(params[:account_group])
        @account_group.accounts.update_all(account_group_id: nil)
        Account.where(id: all_account_ids).update_all(account_group_id: params[:id])

        flash[:success] = "Account Group successfully updated"
        redirect_to :back
      else
        flash[:error] = @account_group.errors.full_messages
        redirect_to :back
      end
    end
  end

  def update_email_setting
   @account_group  = AccountGroup.find(params[:account_group_id])
   setting_hash = params[:account_group][:email_setting]
   to = setting_hash[:to].gsub(/\s/,"").split(",")
   cc = setting_hash[:cc].gsub(/\s/,"").split(",")
   bcc = setting_hash[:bcc].gsub(/\s/,"").split(",")
   subject = setting_hash[:subject].strip
   addressee = setting_hash[:addressee].strip
   email_setting = {to: to, cc: cc, bcc: bcc, subject: subject, addressee: addressee}
   custom_email_text = params[:account_group][:custom_email_text]
   @account_group.update_attributes(email_setting: email_setting, custom_email_text: custom_email_text)
   redirect_to :back
  end
end
