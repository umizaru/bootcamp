# frozen_string_literal: true

class Scheduler::DailyController < SchedulerController
  def show
    User.notify_to_discord
    notify_product_review_not_completed
    Question.notify_certain_period_passed_after_last_answer
    head :ok
    fetch_and_save_rss_feeds
  end

  private

  def notify_product_review_not_completed
    Comment.where(commentable_type: 'Product').find_each do |product_comment|
      product = product_comment.commentable
      if product_comment.certain_period_passed_since_the_last_comment_by_submitter?(5.days) && !product.unassigned? && !product.checked?
        DiscordNotifier.with(comment: product_comment).product_review_not_completed.notify_now
      end
    end
  end

  def fetch_and_save_rss_feeds
    users = User.where(retired_on: nil)

    users.each do |user|
      rss_items = ExternalEntry.parse_rss_feed(user.feed_url)

      next unless rss_items

      rss_items.each do |item|
        next if ExternalEntry.find_by(url: item.link)

        ExternalEntry.save_rss_feed(user, item)
      end
    end
  end
end
