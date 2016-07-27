require 'sprockets'
require 'tilt'
require 'coffee-react'
require 'coffee_script'

module Sprockets
  # Preprocessor that runs CJSX source files through coffee-react-transform
  # then compiles with coffee-script
  class CoffeeReactScript < Tilt::Template
    CJSX_EXTENSION = /\.cjsx[^\/]*?$/
    CJSX_PRAGMA = /^\s*#[ \t]*@cjsx/i

    def prepare
    end

    def evaluate(scope, locals, &block)
      self.class.call(data: data, filename: scope.pathname.to_s)[:data]
    end

    def self.call(input)
      data     = input[:data]
      pathname = input[:filename]

      result =
        if pathname =~ /\.coffee\.cjsx/
          ::CoffeeReact.transform(data)
        elsif pathname =~ CJSX_EXTENSION || data =~ CJSX_PRAGMA
          ::CoffeeScript.compile(::CoffeeReact.transform(data))
        else
          data
        end

      { data: result }
    end

  end
end
