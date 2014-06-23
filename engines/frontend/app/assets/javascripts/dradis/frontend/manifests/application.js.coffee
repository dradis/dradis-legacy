//= require jquery
//= require bootstrap
//= require_self

jQuery ->
  if $('body').hasClass('unauthenticated')
    $('body').
      removeClass('unauthenticated').
      addClass('alert').
      addClass('alert-error')