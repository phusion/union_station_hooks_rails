require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'base64'

shared_examples_for 'ActiveRecord hooks' do
  it 'logs SQL queries' do
    write_file("#{@app_dir}/app/controllers/home_controller.rb", %Q{
      class HomeController < ActionController::Base
        def index
          db = ActiveRecord::Base.connection
          db.execute('CREATE TABLE IF NOT EXISTS foobar (id INT)')
          db.execute('INSERT INTO foobar VALUES (1)')
          render :text => 'ok'
        end
      end
    })

    start_app

    expect(get('/home')).to eq('ok')

    wait_for_dump_file_existance
    eventually do
      log = read_dump_file
      log =~ /BEGIN: database query 2 \(.*\) .+$/ &&
        log =~ /END: database query 2 \(.*\)$/
    end

    db_lines = read_dump_file.scan(/BEGIN: database query \d+ \(.*\) .+$/)
    expect(db_lines.size).to eq(2)

    db_info = db_lines.map do |line|
      line =~ /BEGIN: database query \d+ \(.*\) (.+)$/
      Base64.decode64($1)
    end

    expect(db_info[0]).to eq("SQL\nCREATE TABLE IF NOT EXISTS foobar (id INT)")
    expect(db_info[1]).to eq("SQL\nINSERT INTO foobar VALUES (1)")
  end
end
