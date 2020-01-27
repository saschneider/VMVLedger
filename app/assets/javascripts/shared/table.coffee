#
# Table CoffeeScript file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

VMV.Table ||= {}

# Pre-defined footer height with body margin. Footer height must match stylesheets/shared/page.scss + 2px.
VMV.Table.FOOTER_WITH_MARGIN_HEIGHT = 90

# Pre-defined minimum table height.
VMV.Table.MIN_HEIGHT = '250px'

#
# Initialise whenever the page is loaded.
#
$ ->
  $(document).ajaxStop(->
    VMV.Table.setup()
  )

  VMV.Table.setup()

#
# Called to open the link associated with a table element.
#
# @param target The target element.
#
VMV.Table.openLink = (target) ->
  href = $(target).attr('data-href')

  $(target).find('td').not('.no-data-href').css('cursor', 'pointer').on 'click', =>
    document.location = href

  return

#
# called to set up tables.
#
VMV.Table.setup = ->
  $('.table tr[data-href]').each (index, element) =>
    VMV.Table.openLink(element)

  return

#
# Called to setup a sticky table header.
#
# @param target The target element.
# @param minimum Set the height to the minimum rather than calculating it?
#
VMV.Table.stickyHeader = (target, minimum = false) ->
  $(target).css('min-height', VMV.Table.MIN_HEIGHT)

  if minimum
    $(target).height(0)
  else
    $(target).height($(window).height() - $(target).position().top - VMV.Table.FOOTER_WITH_MARGIN_HEIGHT)

    $(window).resize(->
      $(target).height($(window).height() - $(target).position().top - VMV.Table.FOOTER_WITH_MARGIN_HEIGHT)
    )

  return
