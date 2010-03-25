module ActionView::Helpers::FormHelper
#  def text_field_with_obfuscation(object_name, method, options = {})
#    '1'
#    #text_field_without_obfuscation(object_name, method, options.reverse_merge(:value => options[:object].send(method)))
#  end
#
#  def secret_field_name(real_field_name)
#    Digest::MD5.hexdigest(File.join(real_field_name, spinner, secret))
#  end
#
#  def spinner
#    @spinner ||= Digest::MD5.hexdigest(File.join(timestamp, client_ip, entry_id, secret))
#  end
#
#  def timestamp
#    @timestamp ||= Time.now.to_i.to_s
#  end
#
#  def client_ip
#    @client_ip ||= template.controller.request.ip.to_s
#  end
#
#  def entry_id
#    @entry_id ||= ((object && object.respond_to?(:id) && object.id) || object_name).to_s
#  end
#
#  def secret
#    @secret ||= (template.form_authenticity_token).to_s
#  end
#
#  def self.included(base)
#    base.class_eval do
#      alias_method_chain :text_field, :obfuscation
#    end
#  end
end
