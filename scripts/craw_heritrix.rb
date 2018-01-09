#!/usr/bin/env ruby
require_relative 'compressor'
require 'time'
require 'pry'

# Pluck YYYY-MM-DD string from a Time object
def pluck_ymd time
  time.to_s.split.first
end

START_TIME  = pluck_ymd(Time.now)
TIME_LIMIT  = 24 * 60 * 60  # 24 hours
JOB_DIR     = "/var/heritrix-3.2.0/jobs/mapaweb"

# Actions and following status (when action is finished)
$status = {
  build:     "Job is Ready",
  launch:    "Job is Active: PREPARING",
  pause:     "Job is Active: PAUSED",
  terminate: "Job is Finished:",
  teardown:  "Job is Unbuilt" }

# Send an action to Heritrix using HTTP
def curl_crawl action=nil
  command = "curl -s -k -u admin:admin --anyauth --location https://mario:8443/engine/job/mapaweb"
  command += " -d 'action=#{action}'" if !action.nil?

  `#{command}`
end

def crawl_error? action
  true if curl_crawl(action).include? "An error occured"
end

# action: crawl action to be done
# time: sleep in minutes
# return: true if action success, false if error
def execute_action action, sleep_time=1
  puts "Action: #{action}. Waiting for action to finish..."
  result_page = curl_crawl action

  while !result_page.include?($status[:"#{action}"]) && !crawl_error?(action)
    sleep(sleep_time * 60)
    result_page = curl_crawl
  end

  return !crawl_error?(action)
end

# Starts heritrix and returns the process ID
def start_heritrix
  cmd_result = `$HERITRIX_HOME/bin/heritrix -a admin:admin -b "0.0.0.0"`  # Start heritrix
  pid_str = cmd_result[/\(pid \d.*\)/]
  return pid_str[5..-2]
end

pid = start_heritrix
start_time = Time.parse START_TIME  # Day at 00:00
crawl_count = 1

# Sleep until it's time for the next crawl
time_now = Time.now
if time_now < start_time
  puts "[SLEEPING] Next crawl: #{start_time}"
  sleep(start_time - time_now)
elsif time_now > start_time
  start_time = Time.parse(pluck_ymd time_now)
end

loop do
  dir_timestamp = pluck_ymd(start_time).gsub('-','')
  puts "Crawl ##{crawl_count} | #{Time.now}"
  start_time = Time.now + 10*60 # Next crawl time

  execute_action "build"
  execute_action "launch"

  # Wait TIME_LIMIT for crawling
  sleep_time = start_time - Time.now  # Crawl interval - time already gone
  puts "Crawling until #{start_time}"
  sleep sleep_time

  status = curl_crawl
  if !status.include?("Job is Finished:")
    execute_action "pause"
  end
  success = execute_action "terminate"

  if !success  # Restart Heritrix
    puts "Heritrix exception: restarting crawler"
    `kill -9 #{pid}`
    pid = start_heritrix
  else
    execute_action "teardown"
  end

  # TODO: Thread to compress crawl using LZMA
  #binding.pry
  #Thread.new do
    #Dir["#{JOB_DIR}/#{dir_timestamp}*"].each do |dir|
  #Pegando o arquivo mais novo, nao achei onde o resto do nome é formado..
  compress_warcs(Dir["#{JOB_DIR}/#{dir_timestamp}*"].max_by{|f| File.mtime(f)},dir_timestamp)
    #end
  #end

  puts "---------------------------------"
  crawl_count += 1
end
