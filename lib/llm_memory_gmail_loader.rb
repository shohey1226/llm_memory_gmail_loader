# frozen_string_literal: true

require_relative "llm_memory_gmail_loader/version"
require "llm_memory/loader"

module LlmMemoryGmailLoader
  class Error < StandardError; end

  class GmailLoader
    include LlmMemory::Loader

    register_loader :gmail

    def load
      {
        content: "aa",
        metatdata: {}
      }
    end
  end
end
