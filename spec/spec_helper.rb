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

ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))

ush_core_path = ENV['USH_CORE_PATH']
if ush_core_path
  require "#{ush_core_path}/lib/union_station_hooks_core"
else
  require 'union_station_hooks_core'
end

UnionStationHooks.require_lib 'spec_helper'
UnionStationHooks.require_lib 'utils'
UnionStationHooks::SpecHelper.initialize!

require("#{ROOT}/lib/union_station_hooks_rails")
require 'json'

module SpecHelper
  def base64(data)
    UnionStationHooks::Utils.base64(data)
  end

  def get_json(path)
    JSON.parse(get(path))
  end

  def post_and_get_response(path, form)
    uri = URI.parse("#{root_url}#{path}")
    Net::HTTP.post_form(uri, form)
  end

  def post(path, form)
    response = post_and_get_response(path, form)
    return_200_response_body(path, response)
  end
end

RSpec.configure do |config|
  config.include(UnionStationHooks::SpecHelper)
  config.include(SpecHelper)
end
