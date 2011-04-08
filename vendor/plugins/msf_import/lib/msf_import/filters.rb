module MsfImport  
  
  module Filters

    #Filter to import everything from Metasploit
    module MsfAll
    NAME = 'Metasploit Import: Import Everything from Metasploit database'
      
      def self.run(params={})
        records = []

        # Create a new Metasploit connection object
        begin 
          c = Msf.new({:host => Configuration.host, 
            :port => Configuration.port.to_i,
            :user => Configuration.user,
            :pass => Configuration.pass})
        rescue MsfError => e
            records << { :title => "Mestasploit XMLRPC",:description => "Error: #{e.reason}" }
            return records
        end

        begin
          hosts = c.hosts
          services = c.services
        rescue MsfError => e
            records << { :title => "Mestasploit XMLRPC",:description => "Error: #{e.reason}" }
            return records
        end

        cat = Category.find_or_create_by_name(Configuration.category)
        parent = Node.find_or_create_by_label(:label => Configuration.node)

        hosts.each do  |host|

          label = ''
          label = host['address'] || host['address6']
          ni = ''

          host.keys.each do  |k|
            ni << "#{k} : #{host[k]}\n" if host[k] != ""
          end

          hnode = Node.find_or_create_by_label(label, :parent_id => parent.id)
          hnote =  Note.find_or_create_by_node_id(hnode.id, :category_id => cat.id, :author => Configuration.author)
          hnote.text = ni
          hnote.save
          
        end

        services.each do  |service|

          label = ''
          label = "#{service['port']}/#{service['proto']}"
          si = ''

          service.keys.each do  |k|
            si << "#{k} : #{service[k]}\n" if service[k] != ""
          end

          host = Node.find_by_label_and_parent_id(service['host'],  parent.id)
          port = Node.find_or_create_by_label_and_parent_id(label, host.id)
          pnote =  Note.find_or_create_by_node_id(port.id, :category_id => cat.id, :author => Configuration.author)
          pnote.text = si
          pnote.save

        end
 
        hosts.each do |host|

          begin 
            notes = c.get_notes({:host => host['address'] })
          rescue MsfError => e
            records << { :title => "Mestasploit XMLRPC",:description => "Error: #{e.reason}" }
            return records
          end

          notes.each do |note|

            slabel = nil
            slabel = "#{note['port']}/#{note['proto']}" if note['port'] != "" and note['proto'] != ""
            hostobj = Node.find_by_label_and_parent_id(host["address"] || host["address6"],parent.id)
            pid = hostobj.id
   
            if slabel
              service = Node.find_by_label_and_parent_id(slabel,pid)
              pid = service.id if service
            end
   
            noteobj = Node.find_or_create_by_label_and_parent_id(note['ntype'],pid)
            ni = ''
   
            note.keys.each do |k|
            
              if note[k].class == Hash
                ni << "#{k}\n"
                note[k].each { |sk,v| ni << "\t#{sk} : #{v}\n" }
              else
                ni << "#{k} : #{note[k]}\n" if note[k] != ""
              end
            end
   
            nnote =  Note.find_or_create_by_node_id(noteobj.id, :category_id => cat.id, :author => Configuration.author)
            nnote.text = ni
            nnote.save

          end

          begin 
            vulns = c.get_vulns({:host => host['address'] })
          rescue MsfError => e
            records << { :title => "Mestasploit XMLRPC",:description => "Error: #{e.reason}" }
            return records
          end

          vulns.each do |vuln|

            slabel = nil
            slabel = "#{vuln['port']}/#{vuln['proto']}" if vuln['port'] != "" and vuln['proto'] != ""
            hostobj = Node.find_by_label_and_parent_id(host["address"] || host["address6"],parent.id)
            pid = hostobj.id
   
            if slabel
              service = Node.find_by_label_and_parent_id(slabel,pid)
              pid = service.id if service
            end
   
            noteobj = Node.find_or_create_by_label_and_parent_id(vuln['name'],pid)
            ni = ''
   
            vuln.keys.each do |k|

              if vuln[k].class == Hash
                ni << "#{k}\n"
                vuln[k].each { |sk,v| ni << "\t#{sk} : #{v}\n" }
              elsif vuln[k].class == Array
                ni << "#{k} : #{vuln[k].join(" , ")}\n"
              else
                ni << "#{k} : #{vuln[k]}\n" if vuln[k] != ""
              end

            end
   
            nnote =  Note.find_or_create_by_node_id(noteobj.id, :category_id => cat.id, :author => Configuration.author)
            nnote.text = ni
            nnote.save
            
          end

        end
   
        records << { :title => "Mestasploit XMLRPC",:description => "The filter ran successfully and the data has been imported. Refresh the tree view to show the new nodes." }
        return records

      end
    end
  end  
end
