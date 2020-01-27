#
# Cookie notice CoffeeScript file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

#
# Initialise whenever the page is loaded.
#
$ ->
  $(document).on 'click', '[data-dismiss-cookie-notice]', (event) ->
    VMV.dismissCookieNotice(@)
    event.preventDefault()

#
# Dismisses the cookie notice and sets a cookie.
#
# @param target The target element.
#
VMV.dismissCookieNotice = (target) ->
  toHide = $(target).attr('data-target')

  document.cookie = 'dismiss_cookie_notice=1; path=/'
  $(toHide).hide()

  return
