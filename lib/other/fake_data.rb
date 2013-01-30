class Transaction
  def fake_id_string
    self.name + self.email + self.purchaser_id
  end

  def fake_browser
    Digest::SHA1.hexdigest(fake_id_string)
  end

  def fake_card
    (Digest::MD5.hexdigest(fake_browser)[0,4].hex % 10000).to_s
  end

  def fakeify
    other_data = YAML.load(self.other_data)
    other_data["cc_digest"] = fake_card
    self.other_data = other_data
    self.device_id = fake_browser
    save
  end
end