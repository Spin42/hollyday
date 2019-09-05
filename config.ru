ENV['RACK_ENV'] ||= 'development'

Bundler.require :default

require_relative 'service'
require_relative 'models'
require_relative 'commands'
require_relative 'api'
require_relative 'messages'
require 'yaml'
require 'erb'

ActiveRecord::Base.establish_connection(
  YAML.safe_load(
    ERB.new(
      File.read('config/postgresql.yml')
    ).result, [], [], true
  )[ENV['RACK_ENV']]
)

NewRelic::Agent.manual_start

SlackRubyBotServer::App.instance.prepare!
SlackRubyBotServer::Service.start!

run Api::Middleware.instance
