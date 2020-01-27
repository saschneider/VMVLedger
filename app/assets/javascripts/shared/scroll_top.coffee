#
# Scroll top CoffeeScript file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

VMV.ScrollTop ||= {}

#
# Initialise whenever the page is loaded.
#
VMV.ScrollTop.scrollTop = (target) ->
  $(window).on('scroll', ->
    VMV.ScrollTop.scroll(target)
  )

  $(target).on('click', ->
    document.body.scrollTop = 0 # For Safari.
    document.documentElement.scrollTop = 0 # For Chrome, Firefox, IE and Opera.
  )

  return

#
# Called when the window is scrolled.
#
VMV.ScrollTop.scroll = (target) ->
  if (document.body.scrollTop > 20) or (document.documentElement.scrollTop > 20)
    $(target).removeClass('d-none')
  else
    $(target).addClass('d-none')

  return
