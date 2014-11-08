AWS_CONFIG = {
  :provider => 'AWS',
  :aws_access_key_id => Rails.application.secrets.aws_key,
  :aws_secret_access_key => Rails.application.secrets.aws_secret
}
