# frozen_string_literal: true

require 'optparse'

module ExtractValue
  class OptparseExample
    class ScriptOptions
      attr_accessor :expression, :verbose, :write, :max, :label, :trunk

      def initialize
        self.verbose = false
        self.write = false
        self.max = 300
        self.trunk = 50
      end

      def define_options(parser)
        parser.banner = 'Usage: bin/search -e agua,endesa -t 20 -m 200 -l Agua [options]'
        parser.separator ''
        parser.separator 'Specific options:'

        # add additional options
        expression_option(parser)
        max_option(parser)
        label_option(parser)
        trunk_option(parser)

        boolean_verbose_option(parser)
        boolean_write_option(parser)

        parser.separator ''
        parser.separator 'Common options:'

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
          exit
        end
        # Another typical switch to print the version.
        parser.on_tail('--version', 'Show version') do
          puts ExtractValue::VERSION
          exit
        end
      end

      def expression_option(parser)
        parser.on('-e EXPRESSION', '--expression EXPRESSION', '[REQUIRED] What label you are looking for, coma as separator', String) do |expression|
          self.expression = expression
        end
      end

      def max_option(parser)
        parser.on('-m MAX', '--max MAX', '[OPTIONAL] Keep only amount less than', Integer) do |max|
          self.max = max
        end
      end

      def trunk_option(parser)
        parser.on('-t TRUNK', '--trunk TRUNK', '[OPTIONAL] Trunk label', Integer) do |trunk|
          self.trunk = trunk
        end
      end

      def label_option(parser)
        parser.on('-l LABEL', '--label LABEL', '[OPTIONAL] Labelled the items', String) do |label|
          self.label = label
        end
      end

      def boolean_verbose_option(parser)
        # Boolean switch.
        parser.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          self.verbose = v
        end
      end

      def boolean_write_option(parser)
        parser.on('-w', '--[no-]write', 'Write the result in csv') do |w|
          self.write = w
        end
      end
    end

    #
    # Return a structure describing the options.
    #
    def parse(args)
      # The options specified on the command line will be collected in
      # *options*.
      @options = ScriptOptions.new
      @option_parser = OptionParser.new do |parser|
        @options.define_options(parser)
        parser.parse!(args)
      end
      @options
    end

    attr_reader :parser, :options, :option_parser
  end # class OptparseExample

  class Ui
    def initialize
      example = OptparseExample.new
      @options = example.parse(ARGV)

      unless options.expression
        help(example.option_parser)
        exit(1)
      end
    end

    def search
      ExtractValue::Main.new(options).extract_value
    end

    def help(opts)
      puts(opts)
    end

    attr_reader :options
  end
end
