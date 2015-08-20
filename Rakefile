#  Union Station - https://www.unionstationapp.com/
#  Copyright (c) 2015 Phusion Holding B.V.
#
#  "Union Station" and "Passenger" are trademarks of Phusion Holding B.V.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

if defined?(Bundler)
  # Undo Bundler environment so that calls to 'bundle install' won't try to
  # access the .bundle directory in the gem's toplevel directory.
  clean_env = nil
  Bundler.with_clean_env do
    clean_env = ENV.to_hash
  end
  ENV.replace(clean_env)
  ARGV.each do |arg|
    if arg =~ /^(\w+)=(.*)$/m
      ENV[$1] = $2
    end
  end
end

ush_core_path = ENV['USH_CORE_PATH']
if ush_core_path
  require "#{ush_core_path}/lib/union_station_hooks_core"
else
  require 'union_station_hooks_core'
end

require File.expand_path(File.dirname(__FILE__) + '/lib/union_station_hooks_rails')

require 'shellwords'

desc 'Install the gem bundles of test apps'
task :install_test_app_bundles do
  bundle_args = ENV['BUNDLE_ARGS']
  Dir['rails_test_apps/*'].each do |dir|
    next if !should_run_rails_test?(dir)
    begin
      sh "cd #{dir} && " \
        "ln -s #{Shellwords.escape UnionStationHooks::ROOT} ush_core && " \
        "ln -s #{Shellwords.escape UnionStationHooksRails::ROOT} ush_rails && " \
        "bundle install --without development doc #{bundle_args}"
    ensure
      sh "cd #{dir} && rm -f ush_core ush_rails"
    end
  end
end

desc 'Run tests'
task :spec do
  if ENV['E']
    arg = "-e #{Shellwords.escape ENV['E']}"
  end
  sh "bundle exec rspec -c -f d #{arg}".strip
end

task :test => :spec

desc 'Build gem'
task :gem do
  sh 'gem build union_station_hooks_rails.gemspec'
end


def should_run_rails_test?(dir)
  # Rails >= 4.0 requires Ruby >= 1.9
  RUBY_VERSION >= '1.9' || File.basename(dir) < '4.0'
end
