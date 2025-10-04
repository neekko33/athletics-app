# Use database-backed sessions instead of cookie store
# This prevents session overflow errors when dealing with large amounts of data
Rails.application.config.session_store :active_record_store,
  key: "_athletics_app_session",
  expire_after: 2.weeks
