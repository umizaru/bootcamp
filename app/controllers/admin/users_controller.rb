# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i[show edit update]
  before_action :only_job_seek_update, only: %i[update], if: :only_job_seeking? 

  def index
    @direction = params[:direction] || 'desc'
    @target = params[:target] || 'student_and_trainee'
    @users = User.with_attached_avatar
                 .preload(%i[company course])
                 .order_by_counts(params[:order_by] || 'id', @direction)
                 .users_role(@target)
    @emails = User.users_role(@target).pluck(:email)
  end

  def show
    render action: :show, layout: nil
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: 'ユーザー情報を更新しました。'
    else
      render :edit
    end
  end

  def destroy
    # 今後本人退会時に処理が増えることを想定し、自分自身は削除できないよう
    # 制限をかけておく
    redirect_to admin_users_url, alert: '自分自身を削除する場合、退会から処理を行ってください。' if current_user.id == params[:id]
    user = User.find(params[:id])
    user.destroy
    redirect_to admin_users_url, notice: "#{user.name} さんを削除しました。"
  end

  private

  def set_user
    @user = if Talk.find_by(id: params[:id]).nil?
              User.find(params[:id])
            else
              User.find(Talk.find(params[:id]).user_id)
            end
  end

  def user_params
    params.require(:user).permit(
      :adviser, :login_name, :name,
      :name_kana, :email, :course_id,
      :description, :discord_account, :github_account,
      :twitter_account, :facebook_url, :blog_url, :times_url,
      :password, :password_confirmation, :job,
      :organization, :os, :study_place,
      :experience, :prefecture_code, :company_id,
      :trainee, :job_seeking, :nda,
      :graduated_on, :retired_on, :free,
      :job_seeker, :github_collaborator,
      :officekey_permission, :tag_list, :training_ends_on
    )
  end

  def only_job_seek_update
    if @user.update(user_params)
      redirect_to talk_url, notice: "#{@user.login_name}の就職活動中の情報を更新しました。"
    else
      redirect_to talk_url, alert: "#{@user.login_name}の就職活動中の情報を更新できませんでした。"
    end
  end

  def only_job_seeking?
    user_params.keys.one? && user_params.key?('job_seeking')
  end
end
