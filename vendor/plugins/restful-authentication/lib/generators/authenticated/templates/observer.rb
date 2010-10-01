class <%= class_name %>Observer < ActiveRecord::Observer

  def after_create(<%= file_name %>)
    <%= class_name %>Mailer.signup_notification(<%= file_name %>).deliver
  end

  def after_save(<%= file_name %>)
    <% if options[:include_activation] %><%= class_name %>Mailer.activation(<%= file_name %>).deliver if <%= file_name %>.recently_activated?<% end %>
  end

end
