Factory.define :node do |f|
  f.label "Node-#{Time.now.to_i}"
  f.parent_id nil 
end
