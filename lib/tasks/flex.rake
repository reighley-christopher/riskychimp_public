namespace :flex do
  task :fingerprinter => :environment do
    unless Dir.exist?(FLEX_SDK)
      p "NEED THE FLEX SDK TO BE INSTALLED IN #{FLEX_SDK} IN ORDER TO BUILD THIS FILE."
      p "YOU CAN DOWNLOAD THE FLEX SDK FROM http://www.adobe.com/devnet/flex/flex-sdk-download.html"
      p "IF YOU DISLIKE THE #{FLEX_SDK} DIRECTORY, THEN UPDATE THE VALUE OF FLEX_SDK IN constants.rb"
    end
    %x["#{FLEX_SDK}"bin/mxmlc flash/fingerprint.as -static-link-runtime-shared-libraries]
    %x[cp flash/fingerprint.swf app/assets/flash]
  end
end