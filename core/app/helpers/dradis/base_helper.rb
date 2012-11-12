module Dradis
  module BaseHelper
    def flash_messages
      flash.collect do |name, msg|
        flash_css = 'alert'
        flash_css << {
          :alert => ' alert-error',
          :info => ' alert-info',
          :notice => ' alert-success',
          :warning => ''
          }[name]
        content_tag :div, :class => flash_css do
          [
            link_to('x', '#', :class => 'close', :data => {:dismiss => 'alert'}),
            msg
          ].join("\n").html_safe 
        end 
      end.join("\n").html_safe
    end
  end
end