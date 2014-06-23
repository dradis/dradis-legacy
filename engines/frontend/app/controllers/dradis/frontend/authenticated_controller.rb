# This controller can be a handy one to inherit from if we are building
# functionality that requires the user to be authenticated.
#
# It isolates the code from the authentication implementation as we will be able
# to change the details of the filter without the inheriting classes noticing.
#
# Any third-party code (e.g. plugins) should inherit from this class instead of
# calling the authentication filters directly
class AuthenticatedController < ApplicationController
  before_filter :login_required
  layout 'dradis3'
end