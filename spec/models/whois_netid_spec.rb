require 'spec_helper'

describe WhoisNetid do
  describe "netid" do
    it "should return the first two bytes given IP address, followed by two zeros" do
      WhoisNetid.netid("8.8.8.8").should == "8.8.0.0"
      WhoisNetid.netid("174.232.130.177").should == "174.232.0.0"
    end
  end

  describe "get_whois_from_arin" do
    it "should return the whois arin text" do
      text = WhoisNetid.get_whois_from_arin("174.232.0.0")
      text.should match /[Nn]et[Nn]ame:\W*(.*)$/
    end
  end

  describe "get_whois_from_radb" do
    it "should return the whois radb text" do
      text = WhoisNetid.get_whois_from_radb("174.232.0.0")
      text.should match /descr:\W*(.*)$/
    end
  end

  describe "#whois_arin" do
    it "should return the arin info of the netid, looking it up from whois only if necessary" do
      WhoisNetid.find_by_netid("174.232.0.0").should be_nil
      whois = WhoisNetid.find_or_create_by_netid("174.232.0.0")
      text = whois.whois_arin
      text.should match /[Nn]et[Nn]ame:\W*(.*)$/
      whois.reload
      WhoisNetid.should_not_receive(:get_whois_from_arin)
      whois.whois_arin.should == text
    end
  end

  describe "#whois_radb" do
    it "should return the radb info of the netid, looking it up from whois only if necessary" do
      WhoisNetid.find_by_netid("174.232.0.0").should be_nil
      whois = WhoisNetid.find_or_create_by_netid("174.232.0.0")
      text = whois.whois_radb
      text.should match /descr:\W*(.*)$/
      whois.reload
      WhoisNetid.should_not_receive(:get_whois_from_raddb)
      whois.whois_radb.should == text
    end
  end

  describe "network" do
    it "should return the owner of the network containing a particular IP address" do
      WhoisNetid.network("8.8.8.8").should == "Proxy-registered route object LVLT-ORG-8-8 Level 3 Communications, Inc."
      WhoisNetid.network("174.232.130.177").should ==
          "Verizon Wireless Inc. WIRELESSDATANETWORK Cellco Partnership DBA Verizon Wireless"
      WhoisNetid.network("68.238.198.96").should == " VIS-68-236 Verizon Online LLC"
    end
  end

  describe "network_owner_type" do
    it "should return types of network owner" do
      mobile_verizon = '174.232.130.177'
      mobile_tmobile = '208.54.45.171'
      telecom_comcast = '71.193.95.238'
      telecom_att = '99.88.245.126'
      telecom_verizon = '71.176.6.58'
      university_north_texas = '129.120.76.30'
      university_northwestern = '129.105.245.185'
      random = '69.14.244.91'

      WhoisNetid.network_owner_type(mobile_verizon).should == :mobile
      WhoisNetid.network_owner_type(mobile_tmobile).should == :mobile
      WhoisNetid.network_owner_type(telecom_comcast).should == :telecom
      WhoisNetid.network_owner_type(telecom_att).should == :telecom
      WhoisNetid.network_owner_type(telecom_verizon).should == :telecom
      WhoisNetid.network_owner_type(university_north_texas).should == :school
      WhoisNetid.network_owner_type(university_northwestern).should == :school
      WhoisNetid.network_owner_type(random).should == :unknown
    end
  end
end
