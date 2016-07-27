require 'sprockets'
require 'tilt'
require 'coffee-react'
require 'sprockets/coffee-react-postprocessor'

module Sprockets
  # Preprocessor that runs CJSX source files through coffee-react-transform
  class CoffeeReact < Tilt::Template
    CJSX_EXTENSION = /\.(:?cjsx|coffee)[^\/]*?$/
    CJSX_PRAGMA = /^\s*#[ \t]*@cjsx/i

    def prepare
    end

    def evaluate(scope, locals, &block)
      if scope.pathname.to_s =~ CJSX_EXTENSION || data =~ CJSX_PRAGMA
        ::CoffeeReact.transform(data)
      else
        data
      end
    end

    def self.call(input)
      result = ::CoffeeReact.transform input[:data]
      { data: result }
    end

    def self.install(env = ::Sprockets)
      # Sprockets 3 & 4 support
      if env.respond_to? :register_transformer
        # Ensure CoffeeScript is all set up
        unless env.mime_types['text/coffeescript']
          env.register_mime_type 'text/coffeescript', extensions: ['.coffee', '.js.coffee']
          env.register_transformer 'text/coffeescript', 'application/javascript', Sprockets::CoffeeScriptProcessor
          env.register_preprocessor 'text/coffeescript', Sprockets::DirectiveProcessor.new(comments: ["#", ["###", "###"]])
        end

        # CJSX -> CoffeeScript
        env.register_mime_type 'text/coffeescript+cjsx', extensions: ['.coffee.cjsx']
        env.register_transformer 'text/coffeescript+cjsx', 'text/coffeescript', Sprockets::CoffeeReact

        # CJSX -> JavaScript
        env.register_mime_type 'application/javascript+cjsx', extensions: ['.js.cjsx', '.cjsx']
        env.register_transformer 'application/javascript+cjsx', 'application/javascript', Sprockets::CoffeeReactScript

        # Little bit of prettifying
        env.register_postprocessor 'application/javascript', Sprockets::CoffeeReactPostprocessor

      # Sprockets 2 support
      elsif env.respond_to? :register_engine
        env.register_engine '.cjsx', Sprockets::CoffeeReactScript
        env.register_engine '.js.cjsx', Sprockets::CoffeeReactScript
        env.register_preprocessor 'application/javascript', Sprockets::CoffeeReact
        env.register_postprocessor 'application/javascript', Sprockets::CoffeeReactPostprocessor
      end
    end
  end
end
