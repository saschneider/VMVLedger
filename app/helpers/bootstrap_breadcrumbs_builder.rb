#
# Bootstrap breadcrumbs builder class.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::SimpleBuilder

  #
  # Renders the breadcrumbs. Modified to do this in reverse order.
  #
  def render
    @elements.reverse.collect(&method(:render_element)).join(@options[:separator] || ' &raquo; ')
  end

  #
  # Renders a breadcrumb element. Modified from BreadcrumbsOnRails::Breadcrumbs::SimpleBuilder#render_element.
  #
  # @param element The breadcrumb element to render.
  #
  def render_element(element)
    # Build the link.
    path = nil

    if element.path.nil?
      content = compute_name(element)
    else
      path    = compute_path(element)
      content = @context.link_to_unless_current(compute_name(element), path, element.options)
    end

    # Wrap it in the required tag. Modified to include the required bootstrap classes, checking the current path.
    tag_options = { class: 'breadcrumb-item' }

    if path && @options[:current_path] && (@options[:current_path] == path)
      tag_options[:class] = tag_options[:class] ? tag_options[:class] + ' active' : 'active'
    end

    if @options[:tag]
      @context.content_tag(@options[:tag], content, tag_options)
    else
      ERB::Util.h(content)
    end
  end
end
