class WhoisNetid < ActiveRecord::Base
  attr_accessible :netid, :whois_arin, :whois_radb

  def self.netid(ip)
    return nil unless Util::IP.valid_ip?(ip)
    ip.gsub(/[0-9]*\.[0-9]*$/, '0.0')
  end

  def self.get_whois_from_arin(netid)
    `whois #{netid}`
  end

  def self.get_whois_from_radb(netid)
    `whois -m #{netid}`
  end

  def self.network(ip)
    return nil unless Util::IP.valid_ip?(ip)
    record = WhoisNetid.find_or_create_by_netid(WhoisNetid.netid(ip))
    object1 = record.whois_radb
    capture1 = /descr:\W*(.*)$/.match(object1)
    object2 = record.whois_arin
    capture2 = /[Nn]et[Nn]ame:\W*(.*)$/.match(object2)
    capture3 = /[Oo]rg[Nn]ame:\W*(.*)$/.match(object2)
    (capture1.nil? ? "" : capture1[1]) + " " + (capture2.nil? ? "" : capture2[1]) + " " +
        (capture3.nil? ? "" : capture3[1])
  end

  def whois_arin
    if read_attribute(:whois_arin).nil?
      text = WhoisNetid.get_whois_from_arin(read_attribute(:netid))
      write_attribute(:whois_arin, text)
      self.save
    end
    read_attribute(:whois_arin)
  end

  def whois_radb
    if read_attribute(:whois_radb).nil?
      text = WhoisNetid.get_whois_from_radb(read_attribute(:netid))
      write_attribute(:whois_radb, text)
      self.save
    end
    read_attribute(:whois_radb)
  end

  def self.network_owner_type(ip)
    return nil unless Util::IP.valid_ip?(ip)
    text = self.network(ip)
    mobile_keywords = ['wireless', 'mobile']
    telecom_keywords = ['at&t', 'sprint', 'verizon', 'bt public', 'comcast']
    school_keywords = ['university']
    if mobile_keywords.select {|kw| Regexp.new(kw, 'i') =~ text}.count > 0
      return :mobile
    elsif telecom_keywords.select {|kw| Regexp.new(kw, 'i') =~ text}.count > 0
      return :telecom
    elsif school_keywords.select {|kw| Regexp.new(kw, 'i') =~ text}.count > 0
      return :school
    else
      return :unknown
    end
  end
end
