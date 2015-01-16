# This controller is used by the Ajax poller to retrieve changes made by other
# users.

class LogsController < Dradis::Frontend::AuthenticatedController
  respond_to :json

  # Returns an array of log entries in the form of:
  #  { :id => log.id, :action => 'create|update|destroy', :record => <attributes> }
  def index
    after = params.fetch(:after, 0).to_i
    @logs = Log.where('uid = 0 and id > ?', after).collect do |log_entry|
      event_data = YAML.load(log_entry.text)

      # Avoid re-sending our own events, the interface already has those
      next if event_data[:by] == current_user
      event_data.merge(:id => log_entry.id)
    end

    respond_with(@logs.compact)
  end
end