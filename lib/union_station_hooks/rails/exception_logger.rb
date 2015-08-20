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
    class ExceptionLogger
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue Exception => e
        report_exception(env, e) if env[PASSENGER_TXN_ID]
        raise e
      end

    private
      def report_exception(env, exception)
        options = {}
        request = ActionDispatch::Request.new(env)
        if request.parameters['controller']
          options[:controller_name] = request.parameters['controller'].humanize + "Controller"
          options[:action_name] = request.parameters['action']
        end
        UnionStationHooks.report_request_exception(env, exception, options)
      end
    end
  end # module Rails
end # module UnionStationHooks

if defined?(ActionDispatch::DebugExceptions)
  exceptions_middleware = ActionDispatch::DebugExceptions
elsif defined?(ActionDispatch::ShowExceptions)
  exceptions_middleware = ActionDispatch::ShowExceptions
end
if exceptions_middleware && defined?(Rails)
  Rails.application.middleware.insert_after(
    exceptions_middleware,
    ExceptionLogger)
end
