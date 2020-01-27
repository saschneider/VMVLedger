#
# Active model errors file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Overrides the Errors class full_message method to allow the attribute name to be removed from the message.
module ActiveModel
  class Errors

    #
    # Returns a full message for a given attribute. Does not include the attribute if the message starts with '^'.
    # See https://github.com/joelmoss/dynamic_form/blob/master/lib/active_model/dynamic_errors.rb
    #
    # @param attribute The attribute for which errors are required.
    # @param message The message being output.
    # @return The formatted message.
    #
    def full_message(attribute, message)
      # Copied from based class.
      return message if attribute == :base
      attr_name = attribute.to_s.tr(".", "_").humanize
      attr_name = @base.class.human_attribute_name(attribute, default: attr_name)

      # Modified to look for '^', remove it and not use the translation.
      if message =~ /^\^/
        message[1..-1]
      else
        I18n.t(:'errors.format', default: "%{attribute} %{message}", attribute: attr_name, message: message)
      end
    end
  end
end