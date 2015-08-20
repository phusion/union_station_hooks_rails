#  Union Station - https://www.unionstationapp.com/
#  Copyright (c) 2010-2015 Phusion Holding B.V.
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

PASSENGER_DIR = ENV['PASSENGER_DIR'] || abort("Please set the PASSENGER_DIR environment variable to the Passenger source directory")
require("#{PASSENGER_DIR}/src/ruby_supportlib/phusion_passenger")
PhusionPassenger.locate_directories
PhusionPassenger.require_passenger_lib "constants"

ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
require("#{ROOT}/lib/union_station_hooks")
UnionStationHooks.require_lib "spec_helper"

require "timecop"

DEBUG = !ENV['DEBUG'].to_s.empty?
if DEBUG
  UnionStationHooks.require_lib "log"
  UnionStationHooks::Log.debugging = true
end

RSpec.configure do |config|
  config.include(UnionStationHooks::SpecHelper)
end
