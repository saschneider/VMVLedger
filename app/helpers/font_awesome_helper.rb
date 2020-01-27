#
# Font Awesome helper class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

module FontAwesomeHelper

  # Outputs a Font Awesome icon given the required classes (without the 'fa-' prefix). Defaults to 'aria-hidden' true.
  def fa_icon(classes, options = {})
    aria_hidden = options['aria-hidden'].nil? ? true : options['aria-hidden']
    options.delete('aria-hidden')

    icon_class = options[:icon_class].nil? ? 'fas' : options[:icon_class]
    options.delete(:icon_class)

    more_classes = options[:class].nil? ? '' : options[:class]
    options.delete(:class)

    classes = classes.split(' ').map { |v| "fa-#{v}" }.join(' ')
    content_tag :i, '', options.merge({ class: "#{icon_class} #{classes} #{more_classes}", 'aria-hidden' => aria_hidden })
  end

end