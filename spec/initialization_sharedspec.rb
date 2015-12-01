require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

shared_examples_for 'Initialization' do
  it 'initializes the Union Station Rails hooks' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ApplicationController
        def index
          render :json => {
            :ush_initialized => UnionStationHooks.initialized?,
            :ush_rails_initialized => UnionStationHooksRails.initialized?
          }
        end
      end
    })

    start_app

    expect(get_json('/home')).to eq(
      'ush_initialized' => true,
      'ush_rails_initialized' => true
    )
  end

  it 'raises no error if no initializer file exists' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ApplicationController
        def index
          render :text => 'ok'
        end
      end
    })

    @create_initializer = false
    start_app

    response = get_response('/home')
    expect(response.code).to eq('200')
    expect(response.body).to eq('ok')
  end

  it 'overrides the vendored Union Station hooks bundled with Passenger' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ApplicationController
        def index
          render :json => {
            :ush_vendored => UnionStationHooks.vendored?,
            :ush_rails_vendored => UnionStationHooksRails.vendored?
          }
        end
      end
    })

    start_app

    expect(get_json('/home')).to eq(
      'ush_vendored' => false,
      'ush_rails_vendored' => false
    )
  end
end
