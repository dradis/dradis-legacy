class DradisTasks < Thor
  class Import < Thor
    class Msf < Thor

      namespace     "dradis:import:msf"

      desc "all","Import the hosts, sevices, notes, etc from Metasploit"

      def all()
        require 'config/environment'
        print "Beginning Import of Metasploit Data...\n"
        records = MsfImport::Filters::MsfAll.run({})
        print records.first[:description]
        print "\n"
      end

    end
  end
end
