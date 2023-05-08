# frozen_string_literal: true

require "google/apis/gmail_v1"
require "googleauth"

require_relative "llm_memory_gmail_loader/version"
require_relative "llm_memory_gmail_loader/configuration"
require "llm_memory/loader"

module LlmMemoryGmailLoader
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
  configure # init for default values

  class GmailLoader
    include LlmMemory::Loader

    register_loader :gmail

    def authorize
      key_content = {
        "type" => "service_account",
        "project_id" => LlmMemoryGmailLoader.configuration.google_project_id,
        "private_key_id" => LlmMemoryGmailLoader.configuration.google_private_key_id,
        "private_key" => LlmMemoryGmailLoader.configuration.google_private_key,
        "client_email" => LlmMemoryGmailLoader.configuration.google_client_email,
        "client_id" => LlmMemoryGmailLoader.configuration.google_client_id,
        "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
        "token_uri" => "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url" => "https://www.googleapis.com/robot/v1/metadata/x509/#{LlmMemoryGmailLoader.configuration.google_client_email}"
      }

      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(JSON.dump(key_content)),
        scope: SCOPE
      )
      authorizer.sub = "user@example.com" # Replace with the user's email address
      authorizer
    end

    def load
      {
        content: "aa",
        metatdata: {}
      }
    end
  end
end
