# The Project class represents a project stored in the Meta-Server application
# we are using ActiveResource to communicate with the remote Meta-Server.
#
# A Project represents a unique entity of work. It can be for instance a 
# particular client engagement. Projects do not hold any repository information.
# The information is associated with each Revision of a project. If a re-test of
# a project is undertaken 3 months after the original engagement, a new Revision
# will be attached to the Project containing the re-test data. 
class Project < ActiveResource::Base
  # TODO: Fix this to apply the same patch as we did in the client to be able to
  # have class.site, .user & .password because some combinations cannot be easily
  # converted into URI. See r1081

  # This method takes a MetaServer object as input, configures the ActiveResource
  # URLs for Project and Revision and pulls a list of projects from the remote
  # Meta-Server.
  # 
  # If the configuration in the MetaServer is invalid, and exception will be
  # thrown.
  def self.find_from_metaserver(meta_server)
    Project.site = meta_server.site_url
    Revision.site = Project.site + 'projects/:project_id'
    return Project.find(:all)
  end
end

# The Revision class represents a project's revision as stored in the Meta-Server 
# application we are using ActiveResource to communicate with the remote 
# Meta-Server.
#
# Each Project has a number of revisions associated with it. Every time a change
# is made to the project and commited to the Meta-Server a new revision is 
# created.
#
# See the Project documentation for additional information
class Revision < ActiveResource::Base
end
