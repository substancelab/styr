# frozen_string_literal: true

require "optparse"

require_relative "../config"

class Styr
  class CLI
    class Task < CLI
      attr_accessor :params

      def description
        lines = [
          "usage: #{$0} --target TARGET task [task options]",
          "",
          "Example usage:",
          "",
          "   Run 'uptime' on the production target",
          "   #{$0} --target=production run 'uptime'",
          "",
        ]
        lines.join("\n")
      end
    end
  end
end
