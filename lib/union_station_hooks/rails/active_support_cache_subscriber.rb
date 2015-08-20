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
    class ActiveSupportCacheSubscriber < ActiveSupport::LogSubscriber
      def cache_read(event)
        UnionStationHooks.call_event_pre_hook(event)
        if event.payload[:hit]
          UnionStationHooks.report_cache_hit(nil, event.payload[:key])
        else
          UnionStationHooks.report_cache_miss(nil, event.payload[:key])
        end
      end

      def cache_fetch_hit(event)
        UnionStationHooks.call_event_pre_hook(event)
        UnionStationHooks.report_cache_hit(nil, event.payload[:key])
      end

      def cache_generate(event)
        UnionStationHooks.call_event_pre_hook(event)
        UnionStationHooks.report_cache_miss(nil, event.payload[:key],
          event.duration * 1000)
      end
    end
  end # module Rails
end # module UnionStationHooks

ActiveSupport::Cache::Store.instrument = true

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_request_handler_thread) do
    if defined?(ActiveSupport::Cache::Store)
      # This flag is thread-local, so re-initialize it for every
      # request handler thread.
      ActiveSupport::Cache::Store.instrument = true
    end
  end
end

UnionStationHooks::Rails::ActiveSupportCacheSubscriber.attach_to(:active_support)
