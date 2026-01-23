# frozen_string_literal: true

require "optparse"

require_relative "../config"

class Styr
  class CLI
    class Task < CLI
      attr_accessor :params

      def description
        ""
      end
    end
  end
end
