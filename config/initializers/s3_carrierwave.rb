CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => AWS_S3_CONFIG[:access_key_id],
    :aws_secret_access_key  => AWS_S3_CONFIG[:secret_access_key]
  }
  config.fog_directory = AWS_S3_BUCKET
end