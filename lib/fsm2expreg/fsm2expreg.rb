require_relative '../parameter'
require_relative '../error'
require_relative '../logging'
module Fsm2Expreg
  #----------------------------------------------------------------------------------------------------------------
  # include class
  #----------------------------------------------------------------------------------------------------------------
  include Errors


  #----------------------------------------------------------------------------------------------------------------
  # Message exception
  #----------------------------------------------------------------------------------------------------------------

  ARGUMENT_UNDEFINE = 1800
  GRAMMAR_NOT_FOUND = 1801
  FSM2EXPREG_JS_PATH_NOT_FOUND = 1802
  NODEJS_RUNTIME_NOT_FOUND = 1803
  EXPREG_NOT_CREATE = 1804
  attr :nodejs_dir,
       :nodejs_runtime_path,
       :expreg,
       :logger

  FSM2EXPREG_JS_PATH = File.join(File.dirname(__FILE__), "#{File.basename(__FILE__, '.rb')}.js")


  def convert(grammar_flow)
    init_parameter

    begin

      raise Error.new(GRAMMAR_NOT_FOUND, :values => {:grammar => grammar_flow.absolute_path}) unless  grammar_flow.exist?
      @logger.an_event.debug "grammar flow #{grammar_flow.basename}"
      raise Error.new(FSM2EXPREG_JS_PATH_NOT_FOUND) unless  File.exist?(FSM2EXPREG_JS_PATH)
      @logger.an_event.debug "fsm2expreg js file #{FSM2EXPREG_JS_PATH}"
      raise Error.new(FSM2EXPREG_JS_PATH_NOT_FOUND, :values => {:nodejs_dir => @nodejs_runtime_path}) unless  File.exist?(@nodejs_runtime_path)
      @logger.an_event.debug "nodejs runtime #{@nodejs_runtime_path}"

      @regexp = IO.popen([@nodejs_runtime_path,
                          FSM2EXPREG_JS_PATH,
                          grammar_flow.absolute_path,
                          File.dirname(@nodejs_runtime_path)]).read

    rescue Exception => e
      @logger.an_event.error e.message
      raise Error.new(EXPREG_NOT_CREATE, :error => e)

    else
      @logger.an_event.debug "expreg #{@regexp}"

    ensure


    end

    @regexp
  end

  private
  def init_parameter
    begin
      parameters = Parameter.new(__FILE__)
    rescue Exception => e
      $stderr << e.message << "\n"
    else
      @nodejs_runtime_path = parameters.nodejs_runtime_path.join(File::SEPARATOR)
      @logger = Logging::Log.new(self, :staging => parameters.environment, :debugging => parameters.debugging)
    end
  end


  module_function :convert
  module_function :init_parameter

end