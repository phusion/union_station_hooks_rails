require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/initialization_sharedspec')
require File.expand_path(File.dirname(__FILE__) + '/action_controller_sharedspec')
require File.expand_path(File.dirname(__FILE__) + '/active_record_sharedspec')
require File.expand_path(File.dirname(__FILE__) + '/active_support_caching_sharedspec')
require File.expand_path(File.dirname(__FILE__) + '/benchmarking_sharedspec')

require 'tmpdir'
require 'fileutils'
require 'shellwords'

def should_run_rails_test?(dir)
  # Rails >= 4.0 requires Ruby >= 1.9
  RUBY_VERSION >= '1.9' || File.basename(dir) < '4.0'
end

Dir["#{ROOT}/rails_test_apps/*"].each do |rails_app_dir|
  rails_version = File.basename(rails_app_dir)
  next if !should_run_rails_test?(rails_app_dir)

  describe "Rails #{rails_version} hooks" do
    let(:rails_app_dir) { rails_app_dir }
    let(:rails_version) { rails_version }
    let(:port) { 4928 }
    let(:root_url) { "http://127.0.0.1:#{port}" }

    before :each do
      @tmpdir = Dir.mktmpdir
      @dump_dir = "#{@tmpdir}/dump"
      @app_dir = "#{@tmpdir}/app"
      @create_initializer = true
      @hook_config = {}
      FileUtils.mkdir(@dump_dir)
    end

    after :each do
      stop_app
      FileUtils.rm_rf(@tmpdir)
    end

    def install_app
      FileUtils.ln_s(UnionStationHooks::ROOT,
        "#{@app_dir}/ush_core")
      FileUtils.ln_s(UnionStationHooksRails::ROOT,
        "#{@app_dir}/ush_rails")
      FileUtils.cp_r(Dir["#{rails_app_dir}/*"],
        @app_dir)
      FileUtils.cp_r("#{rails_app_dir}/.bundle",
        @app_dir)
      if @create_initializer
        write_file("#{@app_dir}/config/initializers/union_station.rb", %Q{
          if defined?(UnionStationHooks)
            UnionStationHooks.config.merge!(#{@hook_config.inspect})
            UnionStationHooks.initialize!
          end
        })
      end
    end

    def start_app
      install_app
      Dir.chdir(@app_dir) do
        command = "#{PhusionPassenger.bin_dir}/passenger start " \
          "--address 127.0.0.1 --port #{port} " \
          "--max-pool-size 1 --daemonize --environment production " \
          "--friendly-error-pages " \
          "--union-station-key whatever " \
          "--ctl ust_router_dev_mode=true " \
          "--ctl ust_router_dump_dir=#{Shellwords.escape @dump_dir}"
        output = `#{command} 2>&1`
        if $?.nil? || $?.exitstatus != 0
          raise "Error starting Passenger. This was the command's output:\n" \
            "------ Begin output ------\n" \
            "#{output}\n" \
            "------ End output ------"
        end
      end
    end

    def stop_app
      return if !app_started?
      Dir.chdir(@app_dir) do
        result = system("#{PhusionPassenger.bin_dir}/passenger",
          'stop', '-p', port.to_s)
        if !result
          if $? && $?.termsig
            RSpec.world.wants_to_quit = true
          end
          raise 'Error stopping Passenger'
        end
      end
    end

    def app_started?
      Dir.chdir(@app_dir) do
        system("#{PhusionPassenger.bin_dir}/passenger status " \
          "-p #{port} >/dev/null 2>/dev/null")
      end
    end

    def prepare_debug_shell
      puts "You are at #{@tmpdir}."
      puts "You can find the application's code in 'app'."
      puts "You can find the UstRouter dump files in 'dump'."
      Dir.chdir(@tmpdir)
      if app_started?
        puts "App is listening at: #{root_url}/"
      end
    end

    include_examples "Initialization"
    include_examples "ActiveRecord hooks"
    include_examples "ActionController hooks"
    include_examples "ActiveSupport caching hooks"
    include_examples "Benchmarking hooks"
  end
end
