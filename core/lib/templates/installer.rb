# TODO:
#   - gem vs gemfile generator
#   - Port 3004 + SSL
#     + generate SSL cert
#   - Mount engine on /
#   - rm ./public/index.html
#   - ./db/seeds.rb
#   - copy migrations / create db / run migrations / seed data
#   - precompile assets
#   - switch to Production?
#     + config.serve_static_assets = true in Production
#     + config.assets.precompile += %w( banner.css dradis3.js dradis3.css )



# This application template is inspired by:
#   * https://github.com/resolve/refinerycms/blob/master/templates/refinery/installer.rb
#   * http://railswizard.org/
#

# >----------------------------[ Initial Setup ]------------------------------<

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

@recipes = ['dradis'] 

def recipes; @recipes end
def recipe?(name); @recipes.include?(name) end

def say_custom(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
def say_recipe(name); say "\033[1m\033[36m" + "recipe".rjust(10) + "\033[0m" + "  Running #{name} recipe..." end
def say_wizard(text); say_custom(@current_recipe || 'wizard', text) end

def ask_wizard(question)
  ask "\033[1m\033[30m\033[46m" + (@current_recipe || 'prompt').rjust(10) + "\033[0m\033[36m" + "  #{question}\033[0m"
end

def yes_wizard?(question)
  answer = ask_wizard(question + " \033[33m(y/n)\033[0m")
  case answer.downcase
    when "yes", "y"
      true
    when "no", "n"
      false
    else
      yes_wizard?(question)
  end
end

def no_wizard?(question); !yes_wizard?(question) end

def multiple_choice(question, choices)
  say_custom('question', question)
  values = {}
  choices.each_with_index do |choice,i| 
    values[(i + 1).to_s] = choice[1]
    say_custom (i + 1).to_s + ')', choice[0]
  end
  answer = ask_wizard('Enter your selection:') while !values.keys.include?(answer)
  values[answer]
end

@current_recipe = nil
@configs = {}

@after_blocks = []
def after_bundler(&block); @after_blocks << [@current_recipe, block]; end
@after_everything_blocks = []
def after_everything(&block); @after_everything_blocks << [@current_recipe, block]; end
@before_configs = {}
def before_config(&block); @before_configs[@current_recipe] = block; end

# >---------------------------------[ Dradis ]--------------------------------<

@current_recipe = 'dradis'
@before_configs['dradis'].call if @before_configs['dradis']

gem 'dradis'
gem 'dradis_core'
gem 'dradis-html_export'


# run 'bundle install'
# rake 'db:create'
# generate "refinery:cms --fresh-installation #{ARGV.join(' ')}"
# 
# say <<-SAY
# ============================================================================
# Your new Refinery CMS application is now installed and mounts at '/'
# ============================================================================
# SAY


# >-----------------------------[ Run Bundler ]-------------------------------<

say_wizard "Running Bundler install. This will take a while."
run 'bundle install --quiet'
say_wizard "Running after Bundler callbacks."
@after_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}

@current_recipe = nil
say_wizard "Running after everything callbacks."
@after_everything_blocks.each{|b| config = @configs[b[0]] || {}; @current_recipe = b[0]; b[1].call}
