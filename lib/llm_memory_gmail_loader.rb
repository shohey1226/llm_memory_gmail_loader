# frozen_string_literal: true

require "google/apis/gmail_v1"
require "googleauth"
require "nokogiri"

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

  class GmailLoader
    include LlmMemory::Loader

    register_loader :gmail

    def initialize
      LlmMemoryGmailLoader.configure
    end

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

      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(JSON.dump(key_content)),
        scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY
      )
      # authorizer.sub = "user@example.com" # Replace with the user's email address
    end

    def list_emails(email:, limit: 100)
      @service.authorization.sub = email
      query = "label:sent" # Fetch all sent emails
      next_page_token = nil
      sent_emails = []
      count = 0
      max_results = (limit < 100) ? limit : 100
      loop do
        result = @service.list_user_messages("me", q: query, page_token: next_page_token, max_results: max_results)
        sent_emails.concat(result.messages) if result.messages
        count += result.messages.length

        next_page_token = result.next_page_token
        break if next_page_token.nil?
        break if count > limit
      end

      sent_emails
    end

    def get_email_subject(headers)
      subject_header = headers.find { |header| header.name == "Subject" }
      subject_header&.value
    end

    def get_email_from(headers)
      from_header = headers.find { |header| header.name == "From" }
      if from_header
        from_header.value
      else
        ""
      end
    end

    def extract_email_bodies(payload)
      if payload.mime_type == "text/plain" || payload.mime_type == "text/html"
        {
          text: (payload.mime_type == "text/plain") ? payload.body.data : nil,
          html: (payload.mime_type == "text/html") ? payload.body.data : nil
        }
      elsif payload.mime_type.start_with?("multipart/")
        text_body = nil
        html_body = nil

        payload.parts.each do |part|
          if part.mime_type == "text/plain"
            text_body = part.body.data
          elsif part.mime_type == "text/html"
            html_body = part.body.data
          end
        end

        {
          text: text_body,
          html: html_body
        }
      else
        {
          text: nil,
          html: nil
        }
      end
    end

    def extract_text_from_html(html)
      utf8_html = html.force_encoding("UTF-8")
      document = Nokogiri::HTML(utf8_html)
      document.css("style").remove
      document.css("br").each { |br| br.replace("\n") }
      document.css("a").each do |a|
        link = a["href"]
        text = a.text
        a.replace("#{text} (#{link})") # Replace the <a> tag with its text content and link
      end
      document.text.gsub(/　/, " ").gsub(/\s+/, " ").gsub(/(\r\n)+|\n+/, "\n").strip
    end

    def create_documents(emails)
      docs = []
      emails.each do |email|
        message = @service.get_user_message("me", email.id)
        subject = get_email_subject(message.payload.headers)
        from = get_email_from(message.payload.headers)
        bodies = extract_email_bodies(message.payload)
        if bodies[:text]
          body = bodies[:text].force_encoding("UTF-8").gsub(/　/, " ").gsub(/\s+/, " ").strip
        elsif bodies[:html]
          body = extract_text_from_html(bodies[:html])
        else
          next
        end

        docs.push({
          content: "#{subject}\n#{body}",
          metadata: {
            subject: subject,
            from: from
          }
        })
      end
      docs
    end

    def load(args)
      emails = args[:emails]
      limit = args[:limit]
      raise "emails is required" if emails.nil? || emails.length == 0

      @service ||= Google::Apis::GmailV1::GmailService.new
      @service.authorization = authorize

      results = []
      emails.each do |email|
        results += if limit.nil?
          list_emails(email: email)
        else
          list_emails(email: email, limit: limit)
        end
      end

      create_documents(results)
    end
  end
end
