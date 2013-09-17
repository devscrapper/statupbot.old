require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require_relative 'visitor'


#TODO revisiter l'initiateur des close_connection
module VisitorFactory
  @@logger = nil
  @@busy_visitors = {}
  @@sem_busy_visitors = Mutex.new
  @@return_visitors = []
  @@sem_return_visitors = Mutex.new

  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor_details)

      @@logger.an_event.debug "receive visitor details #{visitor_details}"
      visitor = Visitor.new(visitor_details)
      @@logger.an_event.info "create a visitor with id #{visitor_details[:id]}"
      @@sem_busy_visitors.synchronize { @@busy_visitors[visitor.id] = visitor }
      @@logger.an_event.info "add visitor #{visitor.id} to busy visitors"
      visitor.browser.open()
      visitor.send_customisation_to_mitm
      @@logger.an_event.info "open browser #{visitor.browser.id} of visitor id #{visitor.id}"
      @@logger.an_event.debug @@busy_visitors
    end
  end
  class AssignReturnVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor)
      @@logger.an_event.debug "visitor receive #{visitor.to_s}"
      @@sem_return_visitors.synchronize {
        kill_old_return_visitors()

        if @@return_visitors.empty?
          send_object visitor
          @@logger.an_event.warn "repository return visitors is empty"
          visitor.browser.webdriver = Webdriver.new(visitor.browser.visitor_id)
          @@logger.an_event.info "assign webdriver to browser #{visitor.browser.id} of visitor #{visitor.id}"
          @@sem_busy_visitors.synchronize { @@busy_visitors[visitor.browser.visitor_id] = visitor }
          @@logger.an_event.info "add visitor #{visitor.id} to busy visitors"
          @@logger.an_event.debug @@busy_visitors
          visitor.browser.open()
          @@logger.an_event.info "open browser #{visitor.browser.id}"

        else
          return_visitor = @@return_visitors.shift[1]
          @@logger.an_event.info "select and remove return visitor #{return_visitor.id} from return visitors"
          @@logger.an_event.debug @@return_visitors
          webdriver = return_visitor.browser.webdriver
          return_visitor.browser.webdriver = nil
          send_object return_visitor
          @@logger.an_event.debug "return visitor #{return_visitor}"
          return_visitor.browser.webdriver = webdriver
          @@sem_busy_visitors.synchronize { @@busy_visitors[return_visitor.browser.visitor_id] = return_visitor }
          @@logger.an_event.info "add visitor #{return_visitor.id} to busy visitors"
          @@logger.an_event.debug @@busy_visitors
        end
      }
    end
  end
  class ReturnVisitorsConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    #TODO meo les return visitor

    def initialize(logger)
      @@logger = logger
    end

    def post_init()
      @@logger.an_event.info "send repository return visitors(#{@@return_visitors.size})"
      send_object @@return_visitors
    end
  end
  class UnAssignVisitorConnection < EventMachine::Connection
    #TODO meo la liberation des visitors
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor)
      @@logger.an_event.debug "receive visitor #{visitor}"
      @@sem_busy_visitors.synchronize { @@busy_visitors.delete(visitor.id) }
      @@logger.an_event.info "remove visitor #{visitor.id} from busy visitors"
      @@sem_return_visitors.synchronize {
        @@return_visitors << [Time.now, visitor]
        @@logger.an_event.info "add visitor #{visitor.id} to return visitors"
        @@logger.an_event.debug "data repository return visitors #{@@return_visitors}"
      }
      close_connection
      @@logger.an_event.debug "close connection"
    end

    def unbind
    end
  end
  class BrowseUrlConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor_url)
      close_connection
      visitor_id = visitor_url["visitor_id"]
      url = "http://#{visitor_url["url"]}"
      @@logger.an_event.debug visitor_id
      @@logger.an_event.debug url
      begin
        visitor = @@busy_visitors[visitor_id]
        visitor.browser.browse url
        @@logger.an_event.info "visitor #{visitor.id} browse #{url} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
      rescue Exception => e
        @@logger.an_event.error "visitor #{visitor.id} cannot browse url #{url} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
        @@logger.an_event.debug e
      end
    end
  end
  class ClickUrlConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor_url)
      close_connection
      visitor_id = visitor_url["visitor_id"]
      url = "http://#{visitor_url["url"]}"
      @@logger.an_event.debug visitor_id
      @@logger.an_event.debug url
      begin
        visitor = @@busy_visitors[visitor_id]
        @@logger.an_event.info "visitor #{visitor.id} click on #{url} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
        visitor.browser.click url
      rescue Exception => e
        @@logger.an_event.error "visitor #{visitor.id} cannot click on url #{url} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
        @@logger.an_event.debug e
      end
    end
  end
  class SearchUrlConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor_url)
      close_connection
      @@logger.an_event.debug visitor_url
      visitor_id = visitor_url["visitor_id"]
      search_engine = visitor_url["search_engine"]
      landing_page_url = visitor_url["landing_page_url"]
      keywords = visitor_url["keywords"]
      sleeping_time = visitor_url["sleeping_time"]
      count_max_page = visitor_url["count_max_page"]
      @@logger.an_event.debug visitor_id
      @@logger.an_event.debug search_engine
      @@logger.an_event.debug landing_page_url
      @@logger.an_event.debug keywords
      @@logger.an_event.debug sleeping_time
      @@logger.an_event.debug count_max_page

      begin
        visitor = @@busy_visitors[visitor_id]
        @@logger.an_event.info "visitor #{visitor.id} search #{keywords} on search engine #{search_engine} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
        landing_page_found = visitor.browser.search(search_engine, landing_page_url, keywords, sleeping_time, count_max_page)
        @@logger.an_event.warn "landing page url #{landing_page_url} is not found in results search" unless landing_page_found
        @@logger.an_event.info "landing page url #{landing_page_url} is found in results search" if landing_page_found
      rescue Exception => e
        @@logger.an_event.error "visitor #{visitor.id} cannot search #{keywords} on search engine #{search_engine} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
        @@logger.an_event.debug e
      end
    end
  end

  def kill_old_return_visitors()
    #TODO meo la mort des visitors
    @@logger.an_event.debug "before cleaning, count return visitor : #{@@return_visitors.size}"
    old_return_visitors = @@return_visitors.select { |x| x[0] < Time.now - (5 + 5 + 5) * 60 }
    @@logger.an_event.debug "old return visitors(#{old_return_visitors.size}) : #{old_return_visitors}"
    @@return_visitors = @@return_visitors.select { |x| x[0] > Time.now - (5 + 5 + 5) * 60 }
    @@logger.an_event.debug "kept return visitors(#{@@return_visitors.size}) : #{@@return_visitors}"

    old_return_visitors.each { |x|
      @@logger.an_event.info "close browser #{x[1].browser.id} of visitor #{x[1].id}"
      x[1].browser.close
      @@logger.an_event.info "unassign browser #{x[1].browser.id} of visitor #{x[1].id}"
      WebdriverFactory.unassign_browser(x[1].browser)
      CustomizeQueries.delete_custom_gif(x[1].id)
    }
    @@logger.an_event.debug "after cleaning, count return visitor : #{@@return_visitors.size}"
  end


  module_function :kill_old_return_visitors


end