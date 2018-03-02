class Heritrix
  def initialize path, job_name, auth: "admin:admin", bind: "0.0.0.0"
    @path = path
    @job_name = job_name
    @auth = auth
    @bind = bind
    @pid = nil
  end

  def update_seeds(seeds)
    file = File.join(@path, "jobs", @job_name, "seeds.txt")

    File.open(file, "w") do |f|
      seeds.each do |seed|
        f << seed << "\n"
      end
    end
  end

  def start
    unless @pid
      bin = File.join(@path, "bin", "heritrix")
      result = `#{bin} -a #{@auth} -b #{@bind}`

      @pid = (result.match /\(pid (\d*)\)/)[1]
    end
  end

  def stop
    run_action("pause")
    run_action("terminate")
    run_action("teardown")
  end

  def run_job
    run_action("build")
    run_action("launch")
    run_action("unpause")
  end

  def run_action(action)
    `curl -v -d "action=#{action}" -k -u #{@auth} --anyauth --location https://localhost:8443/engine/job/#{@job_name}`
  end
end
