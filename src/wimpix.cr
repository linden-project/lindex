require "commander"
require "yaml"
require "json"
require "front_matter"
require "./wimpix/*"

module Commander
end

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

    cmd.flags.add do |flag|
      flag.name = "conf_path"
      flag.short = "-c"
      flag.long = "--config"
      flag.default = "~/.wimpi/wimpi.yml"
      flag.description = "alternative path to config file."
    end

    cmd.use = "make"
    cmd.short = "create index"
    cmd.long = cmd.short
    cmd.run do |options, arguments|
      if options.bool["verbose"]
        p options
        p arguments
      end

      env = Wimpix::Environment.new(options.string["conf_path"] , options.bool["verbose"])

      idx = Wimpix::MdFmIndexer.new(env)

    end
  end
end

{% if !@type.has_constant? "TESTING" %}
  Commander.run(cli, ARGV)
{% end %}
