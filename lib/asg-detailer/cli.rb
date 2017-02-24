require 'optparse'

include AsgDetailer

module AsgDetailer
  class CLI
    attr_accessor :conf

    def initialize(args)
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: asg-detailer [ option ... ]'

        opts.separator ''
        opts.separator 'Specific options:'

        opts.on('-a', '--asg STRING', String, 'The ASG name') do |asg|
          options[:asg] = asg
        end

        opts.on('-j', '--json', 'Output data as JSON') do |json|
          options[:json] = true
        end

        opts.on('-p', '--pretty-json', 'Output data as pretty_generated JSON') do |pretty|
          options[:pretty] = true
        end
      end

      opt_parser.parse!(args)
      if options[:asg].nil?
        puts opt_parser
        exit
      end

      self.run(options)
    end

    def run(options)
      if options[:pretty]
        Detailer.new(options[:asg]).json_pretty
      elsif options[:json]
        puts Detailer.new(options[:asg]).json
      else
        Detailer.new(options[:asg]).print
      end
    end
  end
end
