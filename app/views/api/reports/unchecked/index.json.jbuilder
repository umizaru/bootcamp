json.reports @reports do |report|
  json.partial! "api/reports/report", report: report
  json.partial! "api/reports/comments", comments: report.comments
  json.user do
    json.partial! "api/users/user", user: report.user
  end
end

json.current_user_id current_user.id
json.totalPages @reports.total_pages
