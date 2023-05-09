# LLM Memory Gmail Loader

The LLM Memory Gmail Loader is a loader plugin designed for the `llm_memory` gem. It enables the retrieval of emails using the Gmail API. To use this plugin, please ensure you have the `llm_memory` gem installed.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

The following syntax is used to load emails:

- `emails`: (required) An array of email addresses you want to retrieve.
- `limit`: (optional) The maximum number of emails to retrieve for each email address. The default value is 100.
- `query`: A text query to filter emails in Gmail. The default value is "label:sent"

```ruby
documents = LlmMemory::Wernicke.load(
              :gmail,
              emails: ["my@example.com"],
              query: "label:sent",
              limit: 10
            )
# [{
#   content: "subject\nbody",
#   metadata: {
#     subject: subject,
#     from: "xx@example.com"
#   }
# },,,]
```

## Prepare Auth keys

### 1. Enable the Gmail API:

1. Go to the Google API Console: https://console.developers.google.com/
2. Create a new project or select an existing one.
3. Click on "Enable APIs and Services" and search for "Gmail API".
4. Enable the Gmail API for your project.

### 2. Create credentials:

1. In the API Console, go to the "Credentials" tab.
2. Click on "Create credentials" and select "Service account".
3. Fill in the required information and click "Create".
4. Grant the necessary roles, such as "Google Workspace Domain-wide Delegation".
5. Download the JSON key file for the service account.

### 3. Delegate domain-wide authority to the service account:

Follow the instructions in this guide to delegate domain-wide authority: https://developers.google.com/identity/protocols/oauth2/service-account#delegatingauthority

## Configuration

To configure the Gmail Loader, you'll need to set up an initializer. By default, it uses the following environment variables:

```
GOOGLE_PROJECT_ID
GOOGLE_PRIVATE_KEY_ID
GOOGLE_PRIVATE_KEY
GOOGLE_CLIENT_EMAIL
GOOGLE_CLIENT_ID
```

### Setting up the Gmail Loader

1. Download the service account JSON file and copy the keys.
2. Add the following configuration block in your initializer:

```ruby
LlmMemoryGmailLoader.configure do |config|
  config.google_project_id = "<your_google_project_id>"
  config.google_private_key_id = "<your_google_private_key_id>"
  config.google_private_key = "<your_google_private_key>"
  config.google_client_email = "<your_google_client_email>"
  config.google_client_id = "<your_google_client_id>"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/llm_memory_gmail_loader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/llm_memory_gmail_loader/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LlmMemoryGmailLoader project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/llm_memory_gmail_loader/blob/master/CODE_OF_CONDUCT.md).
