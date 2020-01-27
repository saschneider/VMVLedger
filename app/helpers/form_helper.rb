#
# Form helper module.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

module FormHelper

  #
  # Outputs a field. This will automatically add any title and the required attribute to the field.
  #
  # @param form The form for which the field is begin output.
  # @param method The form method being used.
  # @param field The field being output.
  # @param options Any options.
  #
  def form_field(form, method, field, options = {})
    modified_options = options.deep_dup
    modified_options.delete(:select_options)

    required = modified_options[:required].nil? ? nil : modified_options[:required]
    modified_options.delete(:required)

    key              = "activerecord.titles.#{form.object.class.name.underscore}.#{field}"
    modified_options = modified_options.merge(title: I18n.t(key)) if I18n.exists?(key)

    required         = form.send(:'required_attribute?', form.object, field) if required.nil?
    modified_options.merge!(required: true, label_class: 'required') if required

    if method == :select
      form.select(field, options[:select_options], modified_options)
    else
      form.send(method, field, modified_options)
    end
  end

end
