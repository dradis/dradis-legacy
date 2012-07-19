FactoryGirl.define do
  factory :node do
    label "Node-#{Time.now.to_i}"
    parent_id nil
  end
  factory :category do |f|
    name "Category-#{Time.now.to_i}"
  end
  factory :note do |f|
    text "Note text at #{Time.now}"
    author "factory-girl"
    association :category
    association :node
  end
end