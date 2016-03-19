require_relative '../lib/parameter'
#####################################################################
#  run_as_service.rb :  service which run (continuously) a process
#                   'do only one simple thing, but do it well'
#####################################################################
# Usage:
#   .... duplicate this file : it will be the core-service....
#   .... modify constantes in beginning of this script....
#   .... modify stop_sub_process() at end  of this script for clean stop of sub-application..
#
#   > ruby run_as_service.rb install   input     ; foo==name of service,
#   > ruby run_as_service.rb uninstall foo
#   > type d:\deamon.log"       ; run_as_service traces
#   > type d:\d.log             ; service traces
#
#####################################################################
class String; def to_dos() self.tr('/','\\') end end
class String; def from_dos() self.tr('\\','/') end end


#--------------------------------------------------------------------------------------------------------------------
# LOAD PARAMETER
#--------------------------------------------------------------------------------------------------------------------
begin
  parameters = Parameter.new(__FILE__)
rescue Exception => e
  $stderr << e.message << "\n"
else
  rubyexe = parameters.runtime_ruby.join(File::SEPARATOR)


  if rubyexe.nil?
    $stderr << "some parameters not define\n" << "\n"
    exit(1)
  end
end


# example with spawn of a ruby process...
SERVICE_SCRIPT = File.expand_path(File.join("..", "..", "run", "#{ARGV[1]}_server.rb"), __FILE__)
SERVICE_DIR = File.expand_path(File.join("..", "..", "run"), __FILE__)
SERVICE_LOG = File.expand_path(File.join("..", "..", "log", "#{ARGV[1]}_daemon.log"), __FILE__)
RUNNEUR_LOG = File.expand_path(File.join("..", "..", "log", "daemon.log"), __FILE__)
#SERVICE_SCRIPT="D:/statupbot/run/input_flow_server.rb"
#SERVICE_DIR="D:/statupbot/run/".to_dos
#SERVICE_LOG="D:/statupbot/log/input_flow_daemon.log".to_dos           # log of stdout/stderr of sub-process
#RUNNEUR_LOG="D:/statupbot/log/deamon.log"             # log of run_as_service

LCMD=[rubyexe,SERVICE_SCRIPT]   # service will do system('ruby text.rb')
SLEEP_INTER_RUN=4               # at each dead of sub-process, wait n seconds before rerun

################### Installation / Desintallation ###################
if ARGV[0]
    require 'win32/service'
    include Win32

    name= ""+(ARGV[1] || $0.split('.')[0])
    if ARGV[0]=="install"
        path = "#{File.dirname(File.expand_path($0))}/#{$0}".tr('/', '\\')
        cmd = rubyexe + " " + path
        # print "Service #{name} installed with\n cmd=#{cmd} ? " ; rep=$stdin.gets.chomp
        # exit! if rep !~ /[yo]/i

        Service.new(
         :service_name     => name,
         :display_name     => name,
         :description      => "Run of #{File.basename(SERVICE_SCRIPT.from_dos)} at #{SERVICE_DIR}",
         :binary_path_name => cmd,
         :start_type       => Service::AUTO_START,
         :service_type     => Service::WIN32_OWN_PROCESS | Service::INTERACTIVE_PROCESS
        )
        puts "Service #{name} installed"
        Service.start(name, nil)
        sleep(3)
        while Service.status(name).current_state != 'running'
            puts 'One moment...' + Service.status(name).current_state
            sleep 1
        end
        while Service.status(name).current_state != 'running'
            puts ' One moment...' + Service.status(name).current_state
            sleep 1
        end
        puts 'Service ' + name+ ' started'      
    elsif ARGV[0]=="desinstall" || ARGV[0]=="uninstall"
        if Service.status(name).current_state != 'stopped'
            Service.stop(name)
            while Service.status(name).current_state != 'stopped'
                puts 'One moment...' + Service.status(name).current_state
                sleep 1
            end
        end
        Service.delete(name)
        puts "Service #{name} stopped and uninstalled"

    else
        puts "Usage:\n > ruby #{$0} install|desinstall [service-name]"
    end 
    exit!
end

#################################################################
#  service run_as_service : service code 
#################################################################
require 'win32/daemon'
include Win32

Thread.abort_on_exception=true
class Daemon
    def initialize
        @state='stopped'
        super
        log("******************** Runneur #{File.basename(SERVICE_SCRIPT)} Service start ***********************")
    end
    def log(*t)
        txt= block_given?()  ? (yield() rescue '?') : t.join(" ")
        File.open(RUNNEUR_LOG, "a"){ |f| f.puts "%26s | %s" % [Time.now,txt] } rescue nil
    end
    def service_pause
        #put activity in pause
        @state='pause'
        stop_sub_process
        log { "service is paused" }
    end
    def service_resume
        #quit activity from pause
        @state='run'
        log { "service is resumes" }
    end
    def service_interrogate
        # respond to quistion status
        log { "service is interogate" }
    end
    def service_shutdown 
        # stop activities before shutdown
        log { "service is stoped for shutdown" }
    end

    def service_init
        log { "service is starting" }
    end
    def service_main
        @state='run'
        while running?
        begin
            if @state=='run'
                log { "starting subprocess #{LCMD.join(' ')} in #{SERVICE_DIR}" }
                @pid=::Process.spawn(*LCMD,{
                    chdir: SERVICE_DIR, 
                    out: SERVICE_LOG, err: :out
                }) 
                log { "sub-process is running : #{@pid}" }
                a=::Process.waitpid(@pid)
                @pid=nil
                log { "sub-process is dead (#{a.inspect})" }
                sleep(SLEEP_INTER_RUN) if @state=='run'
            else
                sleep 3
                log { "service is sleeping" } if @state!='run'
            end
        rescue Exception => e
            log { e.to_s + " " + e.backtrace.join("\n   ")}
            sleep 4
        end
        end
    end

    def service_stop
     @state='stopped'
     stop_sub_process
     log { "service is stoped" }
     exit!
    end
    def stop_sub_process
        ::Process.kill("KILL",@pid) if @pid
        @pid=nil
    end
end

Daemon.mainloop