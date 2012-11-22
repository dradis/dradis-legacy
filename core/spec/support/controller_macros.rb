# Configuration.find_or_create_by_name('password', :value=>'rspec_password')

shared_examples_for "login-required resource" do |path|
  it "should not be able to access this without logging in" do
    visit path

    page.status_code.should_not == 200
    respond_to do |format|
      format.html { redirect_to(login_url) }
      format.json { page.status_code.should == 401 }
    end

    login_as 'etd'
    visit path
    page.status_code.should == 200
  end
end

def login_as(username)
  visit dradis.login_path
  fill_in :username, with: username
  # fill_in :password, with: 'rspec_password'
  click_button 'Log in'
end