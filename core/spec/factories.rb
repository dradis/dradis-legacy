FactoryGirl.define do
  factory :node, :class => Dradis::Node do
    label "Node-#{Time.now.to_i}"
    parent_id nil
  end

  factory :category, :class => Dradis::Category do |f|
    name "Category-#{Time.now.to_i}"
  end

  factory :note, :class => Dradis::Note do |f|
    text "Note text at #{Time.now}"
    author "factory-girl"
    association :category
    association :node
  end
end