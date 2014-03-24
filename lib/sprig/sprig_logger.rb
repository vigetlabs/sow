require 'active_support/inflector'

module Sprig
  class SprigLogger
    def initialize
      @success_count = 0
      @error_count = 0
      @errors = []
    end

    def log_success(seed)
      message = seed.success_log_text
      puts green(message)
      @success_count += 1
    end

    def log_error(seed)
      message = seed.error_log_text
      @errors << seed.record
      puts red(message)
      puts red("#{seed.record}\n#{seed.record.errors.messages}\n")
      @error_count += 1
    end

    def log_summary
      puts 'Seeding complete.'

      if @success_count > 0
        puts green(success_summary)
      else
        puts red(success_summary)
      end

      if @error_count > 0
        puts red(error_summary)

        @errors.each do |error|
          puts red("#{error}\n#{error.errors.messages}\n\n")
        end
      end
    end

    def processing
      print "Planting those seeds...\r"
    end

    private

    def colorize(message, color_code)
      "\e[#{color_code}m#{message}\e[0m"
    end

    def red(message)
      colorize(message, 31)
    end

    def green(message)
      colorize(message, 32)
    end

    def success_summary
      "#{@success_count} #{'seed'.pluralize(@success_count)} successfully planted."
    end

    def error_summary
      "#{@error_count} #{'seed'.pluralize(@error_count)} couldn't be planted:"
    end
  end
end
