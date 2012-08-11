describe "Categories requests" do
  it_should_behave_like "login-required resource", dradis.categories_path(format: :json)
end