# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: %i[show edit update]

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
      Newspaper.publish(:retirement_create, @user)
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
    Newspaper.publish(:learning_destroy, user)
    user.destroy
    redirect_to admin_users_url, notice: "#{user.name} さんを削除しました。"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :adviser, :login_name, :name,
      :name_kana, :email, :course_id, :subscription_id,
      :description, :discord_account, :github_account,
      :twitter_account, :facebook_url, :blog_url, :times_url,
      :password, :password_confirmation, :job,
      :organization, :os, :study_place,
      :experience, :prefecture_code, :company_id,
      :trainee, :job_seeking, :nda,
      :graduated_on, :retired_on, :free,
      :job_seeker, :github_collaborator,
      :officekey_permission, :tag_list, :training_ends_on,
      :profile_image, :profile_name, :profile_job, :mentor,
      :profile_text, authored_books_attributes: %i[id title url cover _destroy]
    )
  end
end
