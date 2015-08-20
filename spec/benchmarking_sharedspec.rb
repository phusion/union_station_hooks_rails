require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fileutils'

shared_examples_for 'Benchmarking hooks' do
  it 'logs ActionController benchmarks' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          if respond_to?(:benchmark)
            benchmark("hello") do
            end
          else
            ActionController::Base.benchmark("hello") do
            end
          end
          render :text => "ok"
        end
      end
    })

    start_app

    expect(get('/home')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('BEGIN: BENCHMARK: hello') &&
        log.include?('END: BENCHMARK: hello')
    end
  end

  it "logs ActionView benchmarks" do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
      end
    })
    write_file("#{@app_dir}/app/views/home/index.html.erb", %Q{
      <% benchmark("hello") do %>
      <% end %>
    })

    start_app
    get('/home')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('BEGIN: BENCHMARK: hello') &&
        log.include?('END: BENCHMARK: hello')
    end
  end
end
