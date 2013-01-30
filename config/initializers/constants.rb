AWS_S3_BUCKET = "riskybiz"

AWS_S3_CONFIG = {
  access_key_id: 'Your_access_key',
  secret_access_key: 'your_secret_access_key'
}

FLEX_SDK = "/Applications/Flex SDK/"

ZIP_LOCATIONS_FILE = (Rails.env == 'test' ? "spec/lib/data/zip_locations_for_spec.csv" : "lib/data/zip_locations.csv")
