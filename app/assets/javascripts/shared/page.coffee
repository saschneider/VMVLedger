#
# Page CoffeeScript file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

VMV.Page ||= {}

#
# Initialise whenever the page is loaded.
#
$ ->
  $(document).ajaxStart(->
    $('#spinner').attr("style", "display: block !important;")
  )
  $(document).ajaxStop(->
    $('#spinner').attr("style", "display: none !important;")
  )
