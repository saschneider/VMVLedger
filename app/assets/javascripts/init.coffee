#
# Initialisation CoffeeScript file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

# Initialise the application object. Based on:
# http://brandonhilkert.com/blog/organizing-javascript-in-rails-application-with-turbolinks/
window.VMV ||= {}

#
# Initialise whenever the page is loaded.
#
$ ->
  VMV.init()

#
# Initialisation for all pages.
#
VMV.init = ->
  # Confirm modal dialogue defaults.
  dataConfirmModal.setDefaults(
    title: gon.modal_confirm_title
    commit: gon.modal_confirm_commit
    cancel: gon.modal_confirm_cancel
  )

  return
