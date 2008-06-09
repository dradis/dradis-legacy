class NodesController < RestfulController
  rest_operations_for :node, :include => :notes
end
