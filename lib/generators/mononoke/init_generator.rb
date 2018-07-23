# frozen_string_literal: true

require 'fileutils'
module Mononoke
  class InitGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    desc 'Generate totoro config file'

    def copy_config_file
      template 'uptime.rb', File.join('config/initializers', 'uptime.yml')
      template 'health_check_controller.rb', File.join('app/controllers', 'health_check_controller.rb')
      append_diagostics_routes unless File.foreach('config/routes.rb').grep(/diagnostics/).present?
    end

    private

    def append_diagostics_routes
      tempfile = File.open('routes.tmp', 'w')
      f = File.new('config/routes.rb')
      f.each do |line|
        tempfile << line
        tempfile << diagnostics_str if /format: :json/.match?(line.downcase)
      end
      f.close
      tempfile.close
      FileUtils.mv('routes.tmp', 'config/routes.rb')
    end

    def diagnostics_str
      @diagnostics_str ||= <<~FOO
            root to: 'health_check#index'
            scope '/diagnostics' do
              get '/quickhealth', to: 'health_check#quick_health'
              get '/health',      to: 'health_check#health'
              get '/version',     to: 'health_check#version'
              get '/uptime',      to: 'health_check#uptime'
            end
      FOO
    end
  end
end
