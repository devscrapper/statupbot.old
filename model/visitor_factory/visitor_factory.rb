require 'rubygems' # if you use RubyGems
require 'socket'
require 'eventmachine'
require_relative 'visitor'



module VisitorFactory
  @@logger = nil
  @@busy_visitors = {}
  @@sem_busy_visitors = Mutex.new
  @@free_visitors = []
  @@sem_free_visitors = Mutex.new

  #--------------------------------------------------------------------------------------------------------------------
  # CONNECTION
  #--------------------------------------------------------------------------------------------------------------------
  class AssignNewVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor_details)
      close_connection
      @@logger.an_event.debug "receive visitor details #{visitor_details}"
      visitor = Visitor.new(visitor_details)
      @@logger.an_event.info "create a visitor with id #{visitor_details[:id]}"
      @@sem_busy_visitors.synchronize { @@busy_visitors[visitor.id] = visitor }
      @@logger.an_event.info "add visitor #{visitor.id} to busy visitors"
      visitor.open_browser
      @@logger.an_event.info "open browser #{visitor.browser.id} of visitor id #{visitor.id}"
      @@logger.an_event.debug @@busy_visitors
    end
  end
  class AssignReturnVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol
    #TODO valider return visitor
    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor)
      visitor_id = nil
      @@sem_free_visitors.synchronize {
        if @@free_visitors.empty?
          @@logger.an_event.debug "receive visitor details #{visitor_details}"
          visitor = Visitor.new(visitor_details)
          @@logger.an_event.info "create a visitor with id #{visitor_details[:id]}"
          @@sem_busy_visitors.synchronize { @@busy_visitors[visitor.id] = visitor }
          @@logger.an_event.info "add visitor #{visitor.id} to busy visitors"
          visitor.open_browser
          @@logger.an_event.info "open browser #{visitor.browser.id} of visitor id #{visitor.id}"
          @@logger.an_event.debug @@busy_visitors
          visitor_id = visitor.id
        else
          return_visitor = @@free_visitors.shift[1]
          @@logger.an_event.info "remove visitor #{return_visitor.id} from free visitors"
          @@logger.an_event.debug @@free_visitors
          @@sem_busy_visitors.synchronize { @@busy_visitors[return_visitor.id] = return_visitor }
          @@logger.an_event.info "add visitor #{return_visitor.id} to busy visitors"
          @@logger.an_event.debug @@busy_visitors
          visitor_id = return_visitor.id
        end
      }
      send_object visitor_id
      close_connection_after_writing
    end
  end

  class UnAssignVisitorConnection < EventMachine::Connection
    include EM::Protocols::ObjectProtocol

    def initialize(logger)
      @@logger = logger
    end

    def receive_object(visitor_id)
      close_connection
      @@logger.an_event.debug "receive visitor #{visitor_id}"
      @@sem_free_visitors.synchronize { @@free_visitors << [Time.now, @@busy_visitors[visitor_id]] }
      @@logger.an_event.info "add visitor #{visitor_id} to free visitors"
      @@sem_busy_visitors.synchronize { @@busy_visitors.delete(visitor_id) }
      @@logger.an_event.info "remove visitor #{visitor_id} from busy visitors"
      @@logger.an_event.debug "free visitors repository #{@@free_visitors}"
      @@logger.an_event.debug "busy visitors repository #{@@busy_visitors}"
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
        @@logger.an_event.info "visitor #{visitor.id} click on url #{url} with browser #{visitor.browser.id}  with access #{visitor.geolocation.class}"
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

  def garbage_free_visitors
    @@logger.an_event.info "garbage free visitors is start"
    @@logger.an_event.debug "before cleaning, count free visitors : #{@@free_visitors.size}"
    @@logger.an_event.debug @@free_visitors
    size = @@free_visitors.size
    @@free_visitors.delete_if { |visitor|
      #if visitor[0] < Time.now - (5 + 5 + 5) * 60
      if visitor[0] < Time.now - 5 * 60
        @@logger.an_event.info "visitor #{visitor[1].id} is killed"
        @@logger.an_event.debug "remove visitor #{visitor[1].id}"
        visitor[1].close_browser
        true
      end
    }
    @@logger.an_event.debug "after cleaning, count free visitors : #{@@free_visitors.size}"
    @@logger.an_event.debug @@free_visitors
    @@logger.an_event.info "garbage free visitors is over, #{size - @@free_visitors.size} visitor(s) was(were) garbage"
  end


  module_function :garbage_free_visitors


end