require 'singleton'
require 'pathname'
require 'yaml'
class Messages
  include Singleton
  MESSAGES_REPO = Pathname(File.join(File.dirname(__FILE__), '..',  'repository', 'message.yml')).realpath
  attr :messages

  def initialize

    raise "repository messages not found" unless File.exist?(MESSAGES_REPO)

       begin
         @messages = YAML::load(File.open(MESSAGES_REPO), "r")
       rescue Exception => e
         raise "failed to load repository messages #{e.message}"
       end

  end

  def [](code)
    @messages[code]
  end
end

