require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

shared_examples_for 'ActionController hooks' do
  it 'logs the controller and action name' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          render :text => 'ok'
        end
      end
    })

    start_app

    expect(get('/home')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?("Controller action: HomeController#index\n")
    end
  end

  it 'logs the HTTP method as interpreted by Rails' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        skip_before_filter :verify_authenticity_token

        def index
          render :text => 'ok'
        end
      end
    })

    start_app

    expect(post('/home', '_method' => 'PUT')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?("Request method: POST\n") &&
        log.include?("Application request method: PUT\n")
    end
  end

  it 'logs uncaught exceptions in controller actions' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          raise 'something went wrong'
        end
      end
    })

    start_app

    expect(get_response('/home').code).to eq('500')

    wait_for_dump_file_existance('exceptions')
    eventually do
      if File.exists?(dump_file_path('exceptions'))
        log = read_dump_file('exceptions')
        log =~ /Request transaction ID: / &&
          log.include?("Message: " + base64("something went wrong")) &&
          log.include?("Class: RuntimeError") &&
          log.include?("Backtrace: ") &&
          log.include?("Controller action: HomeController#index")
      end
    end
  end

  it 'logs controller processing time of successful actions' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          render :text => 'ok'
        end
      end
    })

    start_app

    expect(get('/home')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('BEGIN: framework request processing') &&
        log.include?('END: framework request processing')
    end
  end

  it 'logs controller processing time of failed actions' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          raise 'crash'
        end
      end
    })

    start_app

    expect(get_response('/home').code).to eq('500')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('BEGIN: framework request processing') &&
        log.include?('FAIL: framework request processing')
    end
  end

  it 'logs view rendering time of successful actions' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
        end
      end
    })
    write_file("#{@app_dir}/app/views/home/index.html.erb", %Q{
      hello world
    })

    start_app

    expect(get('/home')).to include('hello world')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('BEGIN: view rendering 1') &&
        log.include?('END: view rendering 1')
    end
  end

  it 'logs view rendering time of failed actions' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
        end
      end
    })
    write_file("#{@app_dir}/app/views/home/index.html.erb", %Q{
      <% raise "crash!" %>
    })

    start_app

    expect(get_response('/home').code).to eq('500')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('BEGIN: view rendering 1') &&
        log.include?('FAIL: view rendering 1')
    end
  end
end
