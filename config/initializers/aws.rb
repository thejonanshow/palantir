AWS.config(
  :access_key_id => Rails.application.secrets.aws_key,
  :secret_access_key => Rails.application.secrets.aws_secret
)
