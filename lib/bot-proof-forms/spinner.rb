class BotProofForms::Spinner
  def initialize(ip, key, secret)
    raise "Shouldn't have a nil ip" unless ip
    raise "Shouldn't have a nil secret" unless secret
    secret = File.join(#Time.now.to_i.to_s,
                                               ip,
                                               key.to_s,
                                               secret)

    #puts secret
    @spinner = Digest::MD5.hexdigest(secret)
    #puts @spinner
  end

  def spinner
    @spinner
  end

  def encode(real_field_name)
    Digest::MD5.hexdigest(File.join(real_field_name.to_s, spinner))
  end
end
