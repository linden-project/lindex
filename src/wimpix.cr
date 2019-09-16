require "commander"
require "./wimpix/*"

cli = Commander::Command.new do |cmd|
  cmd.use = "wimpix"
  cmd.long = "wimpi indexer"

  cmd.run do |options, arguments|
    puts cmd.help # => Render help screen
  end

  cmd.commands.add do |cmd|
    cmd.flags.add do |flag|
      flag.name = "verbose"
      flag.short = "-v"
      flag.long = "--verbose"
      flag.default = false
      flag.description = "Enable more verbose logging."
    end

    cmd.use = "make"
    cmd.short = "create index"
    cmd.long = cmd.short
    cmd.run do |options, arguments|
      if options.bool["verbose"]
        p options
        p arguments
      end
      p "hello world"
    end
  end
end

{% if !@type.has_constant? "TESTING" %}
  Commander.run(cli, ARGV)
{% end %}
