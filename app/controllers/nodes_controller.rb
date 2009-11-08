# This controller exposes the REST operations required to manage the Node 
# resource. See RestfulController for details of the implementation.
class NodesController < RestfulController
  rest_operations_for :node, :include => :notes
end
