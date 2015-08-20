require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

shared_examples_for 'ActiveSupport caching hooks' do
  it 'logs cache hits' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          Rails.cache.write('key1', 'foo')
          Rails.cache.write('key2', 'foo')
          Rails.cache.write('key3', 'foo')
          Rails.cache.read('key1')
          Rails.cache.fetch('key2')
          Rails.cache.fetch('key3') { 'bar' }
          render :text => 'ok'
        end
      end
    })

    start_app

    expect(get('/home')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('Cache hit: key1') &&
        log.include?('Cache hit: key2') &&
        log.include?('Cache hit: key3')
    end
  end

  it 'logs cache misses' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          Rails.cache.read('key1')
          Rails.cache.fetch('key2')
          Rails.cache.fetch('key3') { 'bar' }
          render :text => 'ok'
        end
      end
    })

    start_app
    expect(get('/home')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log.include?('Cache miss: key1') &&
        log.include?('Cache miss: key2') &&
        log =~ /Cache miss \(\d+ usec\): key3/
    end
  end
end
