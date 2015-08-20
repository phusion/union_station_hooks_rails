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

module UnionStationHooks
  module Rails
    ROOT = File.expand_path(File.dirname(__FILE__))
    VERSION_STRING = "1.0.0"

    if !defined?(UnionStationHooks::VERSION_STRING)
      raise "union_station_hooks must be loaded before union_station_hooks/rails is loaded"
    elsif UnionStationHooks::VERSION_MAJOR != 1 || UnionStationHooks::VERSION_MINOR < 0
      raise "This version of the union_station_hooks_rails gem (#{VERSION_STRING}) is " +
        "only compatible with the union_station_hooks_core gem 1.x.x. However, you have " +
        "loaded union_station_hooks_core #{UnionStationHooks::VERSION_STRING}"
    end

    class << self
      def initialize!
        initialize_gc_stats

        UnionStationHooks::Rails.require_lib('action_controller_subscriber')
        UnionStationHooks::Rails.require_lib('active_record_subscriber')
        if defined?(ActiveSupport::Cache::Store)
          UnionStationHooks::Rails.require_lib('active_support_subscriber')
        end
        if defined?(ActionController::Base)
          UnionStationHooks::Rails.require_lib('action_controller_extension')
        end
        if defined?(ActiveSupport::Benchmarkable)
          UnionStationHooks::Rails.require_lib('active_support_benchmarkable_extension')
        end
      end

      def require_lib(name)
        require("#{ROOT}/union_station_hooks/rails/#{name}")
      end

    private
      def initialize_gc_stats
        if GC.respond_to?(:enable_stats)
          GC.enable_stats
        end
        if defined?(GC::Profiler) && GC::Profiler.respond_to?(:enable)
          GC::Profiler.enable
        end
      end
    end
  end # module Rails
end # module UnionStationHooks

UnionStationHooks.initializers << UnionStationHooks::Rails
