# frozen_string_literal: true

class HealthCheckController < ApplicationController
  def index
    render json: { status: 'OK', dockerImage: ENV['DOCKER_IMAGE'] }
  end

  def quick_health
    status, = dependencies_health(hard_dependencies)

    if status
      render json: { status: 'OK', dockerImage: ENV['DOCKER_IMAGE'] }
    else
      head :internal_server_error
    end
  end

  def health
    status, services = dependencies_health(all_dependencies)

    if status
      render json: { status: 'OK', services: services }
    else
      render json: { status: 'ERROR', services: services }, status: :internal_server_error
    end
  end

  def version
    response = {
      version: ENV['APP_VERSION'],
      name:    ENV['APP_NAME'],
      commit:  ENV['COMMIT']
    }
    render json: response
  end

  def uptime
    response = {
      started_at: Application::BOOTED_AT,
      uptime: (Time.now - Application::BOOTED_AT).to_i
    }
    render json: response
  end

  private

  def server_info
    { daemons: daemons }
  end

  def hard_dependencies
    [db_health]
  end

  def all_dependencies
    [db_health, rabbitmq_health]
  end

  def dependencies_health(dependencies)
    dependencies.reduce([true, {}]) do |(status, services), (stat, serv)|
      [status && stat, services.merge(serv)]
    end
  end

  def db_health
    ActiveRecord::Base.establish_connection
    [true,  { db: 'UP' }]
  rescue StandardError => e
    [false, { db: e.message }]
  end

  def rabbitmq_health
    Totoro::Queue.connection
    [true, { rabbitmq: 'UP' }]
  rescue StandardError => e
    [false, { rabbitmq: e.message }]
  end
end
