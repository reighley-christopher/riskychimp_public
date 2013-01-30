class Thumbprint
  ATTRS = [:user_agent, :http_accept_header, :timezone, :screen_info, :utc_offsets, :flash_capabilities, :fonts, :plugins]

  def self.generate(opts = {})
    opts = opts.with_indifferent_access
    entities = []
    ATTRS.each {|k| entities << opts[k]}
    Digest::SHA1.hexdigest(entities.join(''))
  end
end