#ActionView::Helpers::InstanceTag.class_eval do
#  def sanitized_object_name_with_secret
#    sanitized_object_name_without_secret + "1"
#  end
#
#  def sanitized_method_name_with_secret
#    sanitized_method_name_without_secret + "2"
#  end
#
#  alias_method_chain :sanitized_object_name, :secret
#  alias_method_chain :sanitized_method_name, :secret
#end
