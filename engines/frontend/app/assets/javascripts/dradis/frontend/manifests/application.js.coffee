//= require jquery
//= require bootstrap
//= require_self

jQuery ->
  if $('body').hasClass('unauthenticated')
    $('#status').
      css('background-color', 'inherit').
      addClass('alert').
      addClass('alert-error')

  if $('body').hasClass('authenticated')
    $('#status').
      css('background-color', 'inherit').
      addClass('alert').
      addClass('alert-success')