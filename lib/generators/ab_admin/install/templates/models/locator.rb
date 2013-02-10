require 'ya2yaml'
require 'ostruct'

class Locator
  include Singleton
  extend ActiveModel::Naming
  include AbAdmin::Models::Locator

  attr_accessor :files, :data

end