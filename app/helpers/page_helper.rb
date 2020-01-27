#
# Page helper module.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

module PageHelper

  #
  # Returns the difference in time between two Time, Date or DateTime objects. Modified from: https://stackoverflow.com/a/1224769
  #
  # @param from_time The from time.
  # @param to_time The to time.
  # @return The distance between the times in hours and minutes.
  #
  def distance_of_time_in_hours_and_minutes(from_time, to_time)
    result = '00:00'

    if from_time && from_time.respond_to?(:to_time) && to_time && to_time.respond_to?(:to_time)
      from_time = from_time.to_time
      to_time   = to_time.to_time
      distance  = to_time - from_time
      minutes   = (distance.abs / 60).round
      hours     = minutes / 60
      minutes   = minutes - (hours * 60)

      result = '%02i:%02i' % [hours, minutes]
    end

    result
  end

  #
  # Returns a link_to with the specified class attribute if the linked page is the current page.
  #
  # @param name The link name.
  # @param options Any options for the link. Defaults to CSS class 'dropdown-item'.
  # @param block Optional block.
  # @return The link_to item.
  #
  def link_to_active(name = nil, options = nil, html_options = { class: 'dropdown-item' }, &block)
    link = name
    link ||= options

    if current_page?(link)
      html_options         ||= {}
      html_options[:class] = html_options[:class] ? html_options[:class] + ' active' : 'active'
    end

    if options.nil?
      options      = html_options
      html_options = nil
    elsif options.is_a?(Hash)
      html_options[:class] = "#{options[:class]} #{html_options[:class]}" unless html_options[:class].nil?
      options.merge! html_options
    end

    link_to(name, options, html_options, &block)
  end

  #
  # Returns a link_to wrapped in a list item with the specified class attribute if the linked page is the current page.
  #
  # @param name The link name.
  # @param options Any options for the link. Defaults to CSS class 'nav-link'.
  # @param html_options Any options for the list item. Defaults to CSS class 'nav-item'.
  # @param block Optional block.
  # @return The link_to list item.
  #
  def link_to_list_active(name = nil, options = { class: 'nav-link' }, html_options = { class: 'nav-item' }, &block)
    link = name
    link ||= options

    if current_page?(link)
      html_options         ||= {}
      html_options[:class] = html_options[:class] ? html_options[:class] + ' active' : 'active'
    end

    content_tag :li, link_to(name, options, &block), html_options
  end

  #
  # Sets the model used for template error messages. See _notice.html.haml
  #
  def set_page_model(model)
    @model = model
  end

  #
  # Returns the overall page title which may be a specific title concatenated with the application title.
  #
  # @param separator Separator to use between parts of the title. Default " | ".
  # @return The page title.
  # @see specific_title
  #
  def page_title(separator = ' | ')
    [@titles, I18n.t('app_title')].compact.join(separator)
  end

  #
  # Makes a table column sortable.
  #
  # @param column The field to sort by.
  # @param title The title of the field.
  # @param options Optional options hash.
  # @return A sortable column.
  #
  def sortable(column, title = nil, options = {})
    title     ||= column.titleize
    css_class = (column == sort_column) ? "sort-current sort-#{sort_direction}" : nil
    direction = (column == sort_column) && (sort_direction == 'asc') ? 'desc' : 'asc'
    css_title = I18n.t("shared.controls.#{direction}")
    link_to title, options.merge(sort: column, direction: direction), { class: css_class, title: css_title }
  end

  #
  # Allows an array of specific titles to be set for a page.
  #
  # @param titles The array of titles for the page.
  # @see page_title
  #
  def specific_title(titles = nil)
    @titles = titles
  end

end
