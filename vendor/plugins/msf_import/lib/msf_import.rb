# MsfImport

require 'msf'
require 'msf_import/filters'
require 'msf_import/meta'


module MsfImport
  class Configuration < Core::Configurator
    configure :namespace => 'msf_import'
    setting :host, :default => '127.0.0.1'
    setting :port, :default => '55553'
    setting :user, :default => 'msf'
    setting :pass, :default => 'test' 
    setting :category, :default =>  'Metasploit' 
    setting :node, :default => 'Metasploit'
    setting :author, :default => 'Metasploit XMLRPC plugin'
  end
end

# This includes the import plugin module in the dradis import plugin repository
module Plugins
  module Import
    include MsfImport
  end
end
