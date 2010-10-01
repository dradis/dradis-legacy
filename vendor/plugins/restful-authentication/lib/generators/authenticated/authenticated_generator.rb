require 'digest/sha1'
require 'rails/generators/migration'
class AuthenticatedGenerator <  Rails::Generators::NamedBase

  include Rails::Generators::Migration

  argument :controller_name,          :type => :string, :default => 'sessions', :banner => 'ControllerName'

  class_option :skip_routes,          :type => :boolean, :desc => "Don't generate a resource line in config/routes.rb."
  class_option :skip_migration,       :type => :boolean, :desc => "Don't generate a migration file for this model."
  class_option :aasm,                 :type => :boolean, :desc => "Works the same as stateful but uses the updated aasm gem"
  class_option :stateful,             :type => :boolean, :desc => "Builds in support for acts_as_state_machine and generatesactivation code."
  class_option :rspec,                :type => :boolean, :desc => "Generate RSpec tests and Stories in place of standard rails tests."
  class_option :old_passwords,        :type => :boolean, :desc => "Use the older password scheme"
  class_option :include_activation,   :type => :boolean, :desc => "Skip the code for a ActionMailer and its respective Activation Code through email"
  class_option :dump_generator_attrs, :type => :boolean, :desc => "Dump Generator Attrs"

  def self.source_root
    @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end
  
  def initialize(*args, &block)
    super
    controller_base_name
    model_controller_base_name
    load_or_initialize_site_keys()
  end

#  def check_class_naming_collisions
#    # Check for class naming collisions.
#    class_collisions controller_class_path, "#{ controller_class_name }Controller",
#                                            "#{ controller_class_name }Helper"                    # Sessions Controller
#
#    class_collisions model_controller_class_path, "#{ model_controller_class_name }Controller",
#                                                  "#{ model_controller_class_name }Helper"        # Model Controller
#
#    class_collisions class_path, "#{ class_name }",
#                                 "#{ class_name }Mailer",
#                                 "#{ class_name }MailerTest",
#                                 "#{ class_name }Observer"
#
#    class_collisions [], 'AuthenticatedSystem', 'AuthenticatedTestHelper'
#  end

  def create_model_files
    template 'model.rb', File.join('app/models', class_path, "#{ file_name }.rb")
    if options.include_activation?
      template "mailer.rb", File.join('app/mailers', class_path, "#{ file_name }_mailer.rb")
      template "observer.rb", File.join('app/models', class_path, "#{ file_name }_observer.rb")
    end
  end

  def create_controller_files
    template 'controller.rb', File.join('app/controllers', controller_class_path, "#{ controller_file_name }_controller.rb")
    template 'model_controller.rb', File.join('app/controllers', model_controller_class_path, "#{ model_controller_file_name }_controller.rb")
  end

  def create_lib_files
    template 'authenticated_system.rb', File.join('lib', 'authenticated_system.rb')
    template 'authenticated_test_helper.rb', File.join('lib', 'authenticated_test_helper.rb')
  end

  def create_site_key
    template 'site_keys.rb', site_keys_file
  end

  def create_test_files
    if has_rspec?
      # RSpec Specs
      template 'spec/controllers/users_controller_spec.rb', File.join('spec/controllers', model_controller_class_path, "#{ model_controller_file_name }_controller_spec.rb")
      template 'spec/controllers/sessions_controller_spec.rb', File.join('spec/controllers', controller_class_path, "#{ controller_file_name }_controller_spec.rb")
      template 'spec/controllers/access_control_spec.rb', File.join('spec/controllers', controller_class_path, "access_control_spec.rb") 
      template 'spec/controllers/authenticated_system_spec.rb', File.join('spec/controllers', controller_class_path, "authenticated_system_spec.rb")
      template 'spec/helpers/users_helper_spec.rb', File.join('spec/helpers', model_controller_class_path, "#{ table_name }_helper_spec.rb")
      template 'spec/models/user_spec.rb', File.join('spec/models' , class_path, "#{ file_name }_spec.rb")
      #if fixtures_required?
        template 'spec/fixtures/users.yml', File.join('spec/fixtures', class_path, "#{ table_name }.yml")
      #end
      # Cucumber features
      template 'features/step_definitions/ra_navigation_steps.rb', File.join('features/step_definitions/ra_navigation_steps.rb')
      template 'features/step_definitions/ra_response_steps.rb', File.join('features/step_definitions/ra_response_steps.rb')
      template 'features/step_definitions/ra_resource_steps.rb', File.join('features/step_definitions/ra_resource_steps.rb')
      template 'features/step_definitions/user_steps.rb', File.join('features/step_definitions/', "#{ file_name }_steps.rb")
      template 'features/accounts.feature', File.join('features', 'accounts.feature')
      template 'features/sessions.feature', File.join('features', 'sessions.feature')
      template 'features/step_definitions/rest_auth_features_helper.rb', File.join('features', 'step_definitions', 'rest_auth_features_helper.rb')
      template 'features/step_definitions/ra_env.rb', File.join('features', 'step_definitions', 'ra_env.rb')
    else
      template 'test/functional_test.rb', File.join('test/functional', controller_class_path, "#{ controller_file_name }_controller_test.rb")
      template 'test/model_functional_test.rb', File.join('test/functional', model_controller_class_path, "#{ model_controller_file_name }_controller_test.rb")
      template 'test/unit_test.rb', File.join('test/unit', class_path, "#{ file_name }_test.rb") 
      if options.include_activation?
        template 'test/mailer_test.rb', File.join('test/functional', class_path, "#{ file_name }_mailer_test.rb")
      end
      #if fixtures_required?
        template 'spec/fixtures/users.yml', File.join('test/fixtures', class_path, "#{ table_name }.yml")
      #end
    end
  end

  def crete_helper_files
    template 'helper.rb', File.join('app/helpers', controller_class_path, "#{ controller_file_name }_helper.rb")
    template 'model_helper.rb', File.join('app/helpers', model_controller_class_path, "#{ model_controller_file_name }_helper.rb")
  end

  def create_view_files
    # Controller templates
    template 'login.html.erb',  File.join('app/views', controller_class_path, controller_file_name, "new.html.erb")
    template 'signup.html.erb', File.join('app/views', model_controller_class_path, model_controller_file_name, "new.html.erb")
    template '_model_partial.html.erb', File.join('app/views', model_controller_class_path, model_controller_file_name, "_#{ file_name }_bar.html.erb")

    if options.include_activation?
      # Mailer templates
      %w( activation signup_notification ).each do |action|
        template "#{ action }.erb", File.join('app/views', "#{ file_name }_mailer", "#{ action }.html.erb")
      end
    end
  end

  def create_migration
    unless options.skip_migration?
      migration_template 'migration.rb', "db/migrate/create_#{ migration_file_name }.rb"
    end
  end

  def create_routes
    unless options.skip_routes?
      # Note that this fails for nested classes -- you're on your own with setting up the routes.
      route "match '/activate/:activation_code' => '#{ model_controller_plural_name }#activate', :as => :activate, :activation_code => nil"
      route "match 'logout' => '#{ controller_controller_name }#destroy', :as => :logout"
      route "match 'login' => '#{ controller_controller_name }#new', :as => :login"
      route "match 'register' => '#{ model_controller_plural_name }#create', :as => :register"
      route "match 'signup' => '#{ model_controller_plural_name }#new', :as => :signup"
      route "resource #{ controller_singular_name.to_sym.inspect }, :only => [:new, :create, :destroy]"
      route "resources #{ model_controller_plural_name.to_sym.inspect }"
    end
  end

  # Post-install notes
  def create_notes
    case behavior
    when :invoke
      puts "Ready to generate."
      puts ("-" * 70)
      puts "Once finished, don't forget to:"
      puts
      puts "- Install the dynamic_form plugin(error_messages_for was removed from Rails and is now available as a plugin):"
      puts "    Install it with rails plugin install git://github.com/rails/dynamic_form.git"
      if options.include_activation?
        puts "- Add an observer to config/environment.rb"
        puts "    config.active_record.observers = :#{ file_name }_observer"
      end
      if options.aasm?
        puts "- Install the acts_as_state_machine gem:"
        puts "    sudo gem sources -a http://gems.github.com (If you haven't already)"
        puts "    sudo gem install rubyist-aasm"
      elsif options.stateful?
        puts "- Install the acts_as_state_machine plugin:"
        puts "    svn export http://elitists.textdriven.com/svn/plugins/acts_as_state_machine/trunk vendor/plugins/acts_as_state_machine"
      end
      puts "- Add routes to these resources. In config/routes.rb, insert routes like:"
      puts %(    match 'login' => '#{ controller_file_name }#new', :as => :login)
      puts %(    match 'logout' => '#{ controller_file_name }#destroy', :as => :logout)
      puts %(    match 'signup' => '#{ model_controller_file_name }#new', :as => :signup)
      if options.include_activation?
        puts %(    match 'activate/:activation_code' => '#{ model_controller_file_name }#activate', :as => :activate, :activation_code => nil)
      end
      if options.stateful?
        puts  "  and modify the resources :#{ model_controller_file_name } line to include these actions:"
        puts  "    resources :#{ model_controller_file_name } do"
        puts  "      member do"
        puts  "        put :suspend"
        puts  "        put :unsuspend"
        puts  "        delete :purge"
        puts  "      end"
        puts  "    end"
      end
      puts
      puts ("-" * 70)
      puts
      if $rest_auth_site_key_from_generator.blank?
        puts "You've set a nil site key. This preserves existing users' passwords,"
        puts "but allows dictionary attacks in the unlikely event your database is"
        puts "compromised and your site code is not.  See the README for more."
      elsif $rest_auth_keys_are_new
        puts "We've create a new site key in #{ site_keys_file }.  If you have existing"
        puts "user accounts their passwords will no longer work (see README). As always,"
        puts "keep this file safe but don't post it in public."
      else
        puts "We've reused the existing site key in #{ site_keys_file }.  As always,"
        puts "keep this file safe but don't post it in public."
      end
      puts
      puts ("-" * 70)
    when :revoke
      puts
      puts ("-" * 70)
      puts
      puts "Thanks for using restful_authentication"
      puts
      puts "Don't forget to comment out the observer line in environment.rb"
      puts "  (This was optional so it may not even be there)"
      puts "  # config.active_record.observers = :#{ file_name }_observer"
      puts
      puts ("-" * 70)
      puts
    else
      puts "Didn't understand the action '#{ action }' -- you might have missed the 'after running me' instructions."
    end
  end

  def print_generator_attribute_names
    if options.dump_generator_attrs?
      dump_generator_attribute_names
    end
  end

  protected

  # Override with your own usage banner.
  def banner
    "Usage: #{$0} authenticated ModelName [ControllerName]"
  end

  def controller_class_path
    controller_modules.map { |m| m.underscore }
  end

  def controller_file_path
    (controller_class_path + [controller_base_name.underscore]).join('/')
  end

  def controller_class_nesting
    controller_modules.map { |m| m.camelize }.join('::')
  end

  def controller_class_nesting_depth
    controller_modules.size
  end

  def controller_class_name_without_nesting
    camelcase_name(controller_base_name)
  end

  def controller_file_name
    underscored_name(controller_base_name)
  end

  def controller_plural_name
    pluralized_name(controller_base_name)
  end

  def controller_singular_name
    controller_file_name.singularize
  end

  def controller_class_name
    controller_class_nesting.empty? ? controller_class_name_without_nesting : "#{ controller_class_nesting }::#{ controller_class_name_without_nesting }"
  end

  def controller_routing_name # new_session_path
    controller_singular_name
  end

  def controller_routing_path # /session/new
    controller_file_path.singularize
  end

  def controller_controller_name # sessions
    controller_plural_name
  end

  alias_method  :controller_table_name, :controller_plural_name


  def model_controller_class_path
    model_controller_modules.map { |m| m.underscore }
  end

  def model_controller_file_path
    (model_controller_class_path + [model_controller_base_name.underscore]).join('/')
  end

  def model_controller_class_nesting
    model_controller_modules.map { |m| m.camelize }.join('::')
  end

  def model_controller_class_nesting_depth
    model_controller_modules.size
  end

  def model_controller_class_name_without_nesting
    camelcase_name(model_controller_base_name)
  end

  def model_controller_singular_name
    underscored_name(model_controller_base_name)
  end

  def model_controller_plural_name
    pluralized_name(model_controller_base_name)
  end

  def model_controller_class_name
    model_controller_class_nesting.empty? ? model_controller_class_name_without_nesting : "#{ model_controller_class_nesting }::#{ model_controller_class_name_without_nesting }"
  end

  def model_controller_routing_name # new_user_path
    table_name
  end

  def model_controller_routing_path # /users/new
    model_controller_file_path
  end

  def model_controller_controller_name # users
    model_controller_plural_name
  end
  
  alias_method  :model_controller_file_name,  :model_controller_singular_name
  alias_method  :model_controller_table_name, :model_controller_plural_name
  
  private

  def controller_base_name
    @controller_base_name ||= controller_modules.pop
  end

  def controller_modules
    @controller_modules ||= modules(pluralized_controller_name)
  end

  def pluralized_controller_name
    controller_name.pluralize
  end

  def model_controller_name
    name.pluralize
  end

  def model_controller_base_name
    @model_controller_base_name ||= model_controller_modules.pop
  end

  def model_controller_modules
    @model_controller_modules ||= modules(model_controller_name)
  end

  def modules(name)
    name.include?('/') ? name.split('/') : name.split('::')
  end

  def camelcase_name(name)
    name.camelize
  end

  def underscored_name(name)
    camelcase_name(name).underscore
  end

  def pluralized_name(name)
    underscored_name(name).pluralize
  end

  def has_rspec?
    @rspec ||= (options.rspec? && File.exist?(destination_path("spec")))
  end

#  def test_framework?(name)
#    name == test_framework.to_s
#  end
#
#  def fixtures_required?
#    test_framework && Rails::Application.config.generators.options[test_framework][:fixture] != false
#  end
#
#  def test_framework
#    Rails::Application.config.generators.rails[:test_framework]
#  end

  def destination_path(path)
    File.join(destination_root, path)
  end

  #
  # !! These must match the corresponding routines in by_password.rb !!
  #
  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end
  def password_digest(password, salt)
    digest = $rest_auth_site_key_from_generator
    $rest_auth_digest_stretches_from_generator.times do
      digest = secure_digest(digest, salt, password, $rest_auth_site_key_from_generator)
    end
    digest
  end

  #
  # Try to be idempotent:
  # pull in the existing site key if any,
  # seed it with reasonable defaults otherwise
  #
  def load_or_initialize_site_keys
    case
    when defined? REST_AUTH_SITE_KEY
      if (options.old_passwords?) && ((! REST_AUTH_SITE_KEY.blank?) || (REST_AUTH_DIGEST_STRETCHES != 1))
        raise "You have a site key, but --old-passwords will overwrite it.  If this is really what you want, move the file #{site_keys_file} and re-run."
      end
      $rest_auth_site_key_from_generator         = REST_AUTH_SITE_KEY
      $rest_auth_digest_stretches_from_generator = REST_AUTH_DIGEST_STRETCHES
    when options.old_passwords?
      $rest_auth_site_key_from_generator         = nil
      $rest_auth_digest_stretches_from_generator = 1
      $rest_auth_keys_are_new                    = true
    else
      $rest_auth_site_key_from_generator         = make_token
      $rest_auth_digest_stretches_from_generator = 10
      $rest_auth_keys_are_new                    = true
    end
  end

  def site_keys_file
    File.join("config", "initializers", "site_keys.rb")
  end

  def migration_name
    "Create#{ class_name.pluralize.gsub(/::/, '') }"
  end

  def migration_file_name
    "#{ file_path.gsub(/\//, '_').pluralize }"
  end

  #
  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  #
  def self.next_migration_number(dirname) #:nodoc:
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def dump_generator_attribute_names
    generator_attribute_names = [
      :table_name,
      :file_name,
      :class_name,
      :controller_name,
      :controller_class_path,
      :controller_file_path,
      :controller_class_nesting,
      :controller_class_nesting_depth,
      :controller_class_name,
      :controller_singular_name,
      :controller_plural_name,
      :controller_routing_name,                 # new_session_path
      :controller_routing_path,                 # /session/new
      :controller_controller_name,              # sessions
      :controller_file_name,
      :controller_table_name, :controller_plural_name,
      :model_controller_name,
      :model_controller_class_path,
      :model_controller_file_path,
      :model_controller_class_nesting,
      :model_controller_class_nesting_depth,
      :model_controller_class_name,
      :model_controller_singular_name,
      :model_controller_plural_name,
      :model_controller_routing_name,           # new_user_path
      :model_controller_routing_path,           # /users/new
      :model_controller_controller_name,        # users
      :model_controller_file_name,  :model_controller_singular_name,
      :model_controller_table_name, :model_controller_plural_name,
    ]

    generator_attribute_names.each do |attr|
      puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
    end

  end

end

# rails g authenticated FoonParent::Foon SporkParent::Spork -p --force --rspec --dump-generator-attrs
# table_name:                              foon_parent_foons
# file_name:                               foon
# class_name:                              FoonParent::Foon
# controller_name:                         SporkParent::Sporks
# controller_class_path:                   spork_parent
# controller_file_path:                    spork_parent/sporks
# controller_class_nesting:                SporkParent
# controller_class_nesting_depth:          1
# controller_class_name:                   SporkParent::Sporks
# controller_singular_name:                spork
# controller_plural_name:                  sporks
# controller_routing_name:                 spork
# controller_routing_path:                 spork_parent/spork
# controller_controller_name:              sporks
# controller_file_name:                    sporks
# controller_table_name:                   sporks
# controller_plural_name:                  sporks
# model_controller_name:                   FoonParent::Foons
# model_controller_class_path:             foon_parent
# model_controller_file_path:              foon_parent/foons
# model_controller_class_nesting:          FoonParent
# model_controller_class_nesting_depth:    1
# model_controller_class_name:             FoonParent::Foons
# model_controller_singular_name:          foons
# model_controller_plural_name:            foons
# model_controller_routing_name:           foon_parent_foons
# model_controller_routing_path:           foon_parent/foons
# model_controller_controller_name:        foons
# model_controller_file_name:              foons
# model_controller_singular_name:          foons
# model_controller_table_name:             foons
# model_controller_plural_name:            foons
