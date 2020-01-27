#
# Form CoffeeScript file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

VMV.Form ||= {}

#
# Initialise whenever the page is loaded.
#
$ ->
  # Make all selects into bootstrap-select controls with the required defaults. Here we ignore datetime select elements because they don't work well.
  $.fn.selectpicker.Constructor.DEFAULTS.container = 'body'
  $.fn.selectpicker.Constructor.DEFAULTS.style = 'btn-form-control'
  $('select').not('.rails-bootstrap-forms-datetime-select select').selectpicker()

  # Display the file name when selected by the user.
  $('.custom-file-input').on('change', (event) -> VMV.Form.updateFileSelection(event.target))

  # Show direct uploads.
  $(document).on('direct-upload:initialize', (event) ->
    target = $(event.target)
    html = $('.custom-file-label[for=' + target.attr('id') + ']').html()
    $('.custom-file-label[for=' + target.attr('id') + ']').html(html + '<span id="direct-upload-progress-' + event.detail.id + '" class="direct-upload-progress" style="width: 0%"></span>')
    return
  )

  $(document).on('direct-upload:progress', (event) ->
    element = $('#direct-upload-progress-' + event.detail.id)
    element.css('width', event.detail.progress + '%')
    return
  )

#
# Updates the correspinding file name display for a form file input when a file has been selected.
#
# @param target The target file control.
#
VMV.Form.updateFileSelection = (target) ->
  # Remove the "fakepath" from a file input and update the display.
  fileName = $(target).val().replace(/^.*[\\\/]/, '')
  $(target).next('.custom-file-label').html(fileName)

  return
