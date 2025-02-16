# frozen_string_literal: true

require 'application_system_test_case'

class CurrentUser::BookmarksTest < ApplicationSystemTestCase
  test 'show empty message and icon when current user has no bookmarks' do
    user_without_bookmark = User.create!(
      login_name: 'no-bookmarks',
      email: 'no-bookmarks@fjord.jp',
      password: 'testtest',
      name: 'no-bookmarks',
      name_kana: 'ブックマーク ナシ',
      description: 'test',
      course: courses(:course1),
      job: 'office_worker',
      os: 'mac',
      experience: 'inexperienced'
    )
    visit_with_auth '/current_user/bookmarks', user_without_bookmark.login_name
    assert_text 'ブックマークはまだありません。'
    assert_selector 'i.fa-regular.fa-face-sad-tear', visible: false
    assert_no_selector 'input#card-list-tools__action', visible: false
  end

  test 'show edit button and bookmarks when current user has bookmarks' do
    visit_with_auth '/current_user/bookmarks', 'kimura'

    assert_selector 'label', text: '編集'
    assert_selector 'input#card-list-tools__action', visible: false

    assert_text '作業週1日目'
    assert_selector '.card-list-item__label', text: '日報'
    assert_text '今日はローカルで怖話を動かしてみました。rbenv で ruby を動かすのは初めてだったので、色々手間取りました。'
    assert_text 'komagata(コマガタ マサキ)'
    assert_text '2017年01月01日(日) 00:00'
  end

  test 'can delete bookmarks when edit mode is active' do
    visit_with_auth '/current_user/bookmarks', 'kimura'

    assert_selector '.card-list-item', count: 4
    assert_text 'test1'
    assert_no_selector '#bookmark-button'

    find('#spec-edit-mode').click
    assert_selector '#bookmark-button'
    first('#bookmark-button').click

    assert_selector '.card-list-item', count: 3
    assert_no_text 'test1'
  end

  test 'show empty state when all bookmarks are deleted' do
    user_with_one_bookmark = User.create!(
      login_name: 'have-one-bookmark',
      email: 'have-one-bookmark@fjord.jp',
      password: 'testtest',
      name: 'have-one-bookmark',
      name_kana: 'ブックマーク イッケン',
      description: 'test',
      course: courses(:course1),
      job: 'office_worker',
      os: 'mac',
      experience: 'inexperienced'
    )
    user_with_one_bookmark.bookmarks.create!(bookmarkable_id: reports(:report1).id, bookmarkable_type: 'Report')
    visit_with_auth '/current_user/bookmarks', user_with_one_bookmark.login_name

    assert_selector '.card-list-item', count: 1
    find('#spec-edit-mode').click
    first('#bookmark-button').click

    assert_text 'ブックマークはまだありません。'
    assert_selector 'i.fa-regular.fa-face-sad-tear', visible: false
    assert_no_selector 'input#card-list-tools__action', visible: false
  end
end
