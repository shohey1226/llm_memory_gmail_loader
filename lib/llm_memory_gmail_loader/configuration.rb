module LlmMemoryGmailLoader
  class Configuration
    attr_accessor :google_project_id, :google_private_key_id, :google_private_key, :google_client_email, :google_client_id

    def initialize
      @google_project_id = ENV['GOOGLE_PROJECT_ID']
      @google_private_key_id = ENV['GOOGLE_PRIVATE_KEY_ID']
      @google_private_key = ENV['GOOGLE_PRIVATE_KEY']&.gsub("\\n", "\n")
      @google_client_email = ENV['GOOGLE_CLIENT_EMAIL']
      @google_client_id = ENV['GOOGLE_CLIENT_ID']
    end
  end
end
