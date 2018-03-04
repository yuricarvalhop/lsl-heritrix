require 'pry'
require 'open3'
require 'logger'

class Heritrix
  URL = "https://localhost:8443/engine/job/"
  MAX_TRIES = 20
  WAIT_SEC = 5

  def initialize path, job_name, auth: "admin:admin", bind: "0.0.0.0"
    @path = path
    @job_name = job_name
    @url = URL + job_name
    @auth = auth
    @bind = bind
    @pid = nil

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end

  def update_seeds(seeds)
    file = File.join(@path, "jobs", @job_name, "seeds.txt")

    File.open(file, "w") do |f|
      seeds.each do |seed|
        f << seed << "\n"
      end
    end
  end

  def start_heritrix
    unless @pid
      bin = File.join(@path, "bin", "heritrix")
      result = `#{bin} -a #{@auth} -b #{@bind}`

      @pid = (result.match /\(pid (\d*)\)/)[1].to_i
    end
  end

  def stop_heritrix
    stop_job

    loop do
      begin
        Process.kill('SIGTERM', @pid)
      rescue Errno::ESRCH
        @logger.info("Heritrix stopped with success.")
        return
      else
        @logger.info("Waiting for Heritrix to stop.")
        sleep 5
      end
    end
  end

  def stop_job
    terminate_job
    teardown_job
  end

  def teardown_job
    run_and_wait_action("teardown", "Job is Unbuilt")
  end

  def terminate_job
    run_and_wait_action("terminate", "Job is Finished")
  end

  def start_job
    start_heritrix if @pid.nil?
    run_and_wait_action("launch", "Job is Active: RUNNING")
  end

  def run_job
    start_job
    sleep 10 while is_job_running?
    stop_job
  end

  def is_job_running?
    #TODO
    false
    "Job is Active: RUNNING"
  end

  private

  def run_action(action, msg: nil)
    out = `curl -s -d "action=#{action}" -k -u #{@auth} --digest --location #{@url}`

    !msg || (msg && out[msg] != nil)
  end

  def run_and_wait_action(action, msg)
    tries = 0

    while !run_action(action, msg: msg)
      tries += 1

      if tries == MAX_TRIES
        @logger.error("Could not execute '#{action}' on '#{@job_name}'. MAX_TRIES (#{MAX_TRIES}) reached.");
        exit
      end

      @logger.info("Waiting for '#{action}' to be executed on '#{@job_name}'.")
      sleep WAIT_SEC
    end

    @logger.info("Action '#{action}' executed on '#{@job_name}' with success.")
  end
end
