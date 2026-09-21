require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OdekakeNote
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    # time 型（予定の時刻）はタイムゾーン変換しない。UTC に変換されると、
    # 日本時間で9時前の時刻がDB上で後ろに並んでしまうため
    config.active_record.time_zone_aware_types = [ :datetime ]
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
