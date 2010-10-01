require 'test_helper'
require '<%= file_name %>_mailer'

class <%= class_name %>MailerTest < ActionMailer::TestCase

  def setup
    @<%= file_name %> = <%= table_name %>(:quentin)
  end


  test "signup_notification" do
    # Send the email, then test that it got queued
    email = UserMailer.signup_notification(@<%= file_name %>).deliver
   assert !ActionMailer::Base.deliveries.empty?

   assert_equal [@<%= file_name %>.email], email.to
    assert_equal "[YOURSITE] Please activate your new account", email.subject
    assert_match /Your account has been created./, email.encoded
    assert_match /Visit this url to activate your account/, email.encoded
  end

  test "activation" do
    email = UserMailer.activation(@<%= file_name %>).deliver
   assert !ActionMailer::Base.deliveries.empty?

    assert_equal [@<%= file_name %>.email], email.to
    assert_equal "[YOURSITE] Your account has been activated!", email.subject
    assert_match /your account has been activated.  Welcome aboard!/, email.encoded
    assert_match /http\:\/\/YOURSITE\//, email.encoded
  end

end
