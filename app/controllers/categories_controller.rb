# Each Note belongs to a Category. This controller exposes the REST operations
# required to manage the Category resource. See RestfulController for details
# of the implementation.
class CategoriesController < RestfulController
  rest_operations_for :category
end
