Dir["#{File.dirname(__FILE__)}/hooks/*.rb"].sort.each do |path|
  require "ab_admin/hooks/#{File.basename(path, '.rb')}"
end

require 'i18n/core_ext/kernel/surpress_warnings'

ActiveSupport::XmlMini.backend = 'Nokogiri'
InheritedResources.flash_keys = Responders::FlashResponder.flash_keys = AbAdmin.flash_keys
Responders::FlashResponder.namespace_lookup = true
YAML::ENGINE.yamler = 'psych'
::SimpleForm.wrapper_mappings ||= {}
::SimpleForm.wrapper_mappings[:capture_block] = ::SimpleForm.wrapper_mappings[:uploader] = AbAdmin::Views::ContentOnlyWrapper.instance
CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

Time::DATE_FORMATS[:api] = '%d.%m.%Y'
Time::DATE_FORMATS[:path] = '%Y_%m_%d_%H_%M_%S'
Time::DATE_FORMATS[:compare] = '%Y%m%d%H%M'
Time::DATE_FORMATS[:compare_date] = Date::DATE_FORMATS[:compare_date] = '%Y%m%d'

Kernel.suppress_warnings do
  # fixed in master branch
  Russian::LOCALIZE_MONTH_NAMES_MATCH = /(%d|%e|%-d)(.*)(%B)/ if defined? Russian
end

if defined?(Sunrise::FileUpload)
  Sunrise::FileUpload.setup do |config|
    config.base_path = Rails.root.to_s
  end

  Sunrise::FileUpload::Manager.before_create do |env, asset|
    asset.user = env['warden'].user if env['warden']
  end
end

if defined?(Globalize)
  module Globalize
    def self.valid_locale?(loc)
      return false unless loc
      available_locales.include?(loc.to_sym)
    end
  end
end
