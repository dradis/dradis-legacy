Factory.define :node do |f|
  f.label "Node-#{Time.now.to_i}"
  f.parent_id nil 
end

Factory.define :note do |f|
  f.text "Note text at #{Time.now}"
  f.author "factory-girl"
  f.association :category
  f.association :node
end

Factory.define :category do |f|
  f.sequence(:name){ |n| "Category ##{n}" }
end
 
