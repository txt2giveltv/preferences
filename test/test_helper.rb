# Load the plugin testing framework
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rails/test_help'
require 'active_record/railtie'
# Run the migrations
# ActiveRecord::Migration.migrate("#{Rails.root}/db/migrate")
# ActiveRecord::Migrator.new(:up, [ActiveRecord::MigrationProxy.new('CreateTenants', nil, 'db/migrate/create_tenants.rb', '')], ActiveRecord::SchemaMigration, nil).run

# Mixin the factory helper
require File.expand_path("#{File.dirname(__FILE__)}/factory")
Test::Unit::TestCase.class_eval do
  include Factory
end

# Add query counter
# ActiveRecord::Base.connection.clas.class_eval do
#   IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /SHOW FIELDS/]

#   def execute_with_query_record(sql, name = nil, &block)
#     $queries_executed ||= []
#     $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
#     execute_without_query_record(sql, name, &block)
#   end

#   alias_method :execute, :query_record
# end


# ActiveSupport::TestCase.class_eval do
#   self.use_transactional_fixtures = true
#   self.use_instantiated_fixtures = false
#   self.fixture_path = "#{File.dirname(__FILE__)}/fixtures"

#   fixtures :all
# end
