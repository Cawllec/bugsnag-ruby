require 'net/http'
require 'open3'
require 'pp'

When("I configure the bugsnag endpoint") do
  steps %Q{
    When I set environment variable "MAZE_ENDPOINT" to "http://host.docker.internal:#{MOCK_API_PORT}"
  }
end

When("I wait for the app to respond on port {string}") do |port|
  attempts = 0
  up = false
  until attempts >= 10 || up
    attempts += 1
    begin
      uri = URI("http://localhost:#{port}/")
      response = Net::HTTP.get_response(uri)
      up = (response.code == "200")
    rescue EOFError
    end
    sleep 1
  end
  raise "App not ready in time!" unless up
end

When("I navigate to the route {string} on port {string}") do |route, port|
  steps %Q{
    When I open the URL "http://localhost:#{port}#{route}"
    And I wait for 1 second
  }
end

When("I set environment variable {string} to the current IP") do |env_var|
  steps %Q{
    When I set environment variable "#{env_var}" to "#{current_ip}"
  }
end
When("I set environment variable {string} to the mock API port") do |env_var|
  steps %Q{
    When I set environment variable "#{env_var}" to "#{MOCK_API_PORT}"
  }
end
When("I set environment variable {string} to the proxy settings with credentials {string}") do |env_var, credentials|
  steps %Q{
    When I set environment variable "#{env_var}" to "#{credentials}@#{current_ip}:#{MOCK_API_PORT}"
  }
end

Then("the request used payload v4 headers") do
  steps %Q{
    Then the "bugsnag-api-key" header is not null
    And the "bugsnag-payload-version" header equals "4.0"
    And the "bugsnag-sent-at" header is a timestamp
  }
end

Then("the request contained the api key {string}") do |api_key|
  steps %Q{
    Then the "bugsnag-api-key" header equals "#{api_key}"
    And the payload field "apiKey" equals "#{api_key}"
  }
end

Then("the request used the Ruby notifier") do
  steps %Q{
    Then the payload field "notifier.name" equals "Ruby Bugsnag Notifier"
    And the payload field "notifier.url" equals "http://www.bugsnag.com"
  }
end

Then("the event {string} is {string}") do |key, value|
  steps %Q{
    Then the event "#{key}" equals "#{value}"
  }
end

Then("I output the logs for container {string}") do |container|
  d_id = run_command("docker ps -qa").first
  log = run_command("docker logs #{d_id}")
  log.each do |line|
    pp line
  end
end