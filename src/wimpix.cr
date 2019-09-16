require "commander"

cli = Commander::Command.new do |cmd|
  cmd.use = "wimpix"
  cmd.long = "wimpi indexer"

  cmd.flags.add do |flag|
    flag.name = "verbose"
    flag.short = "-v"
    flag.long = "--verbose"
    flag.default = false
    flag.description = "Enable more verbose logging."
  end

  cmd.commands.add do |cmd|
    cmd.use = "make"
    cmd.short = "create index"
    cmd.long = cmd.short
    cmd.run do |options, arguments|
      p options
      p arguments # => ["62719"]
    end
  end
end

Commander.run(cli, ARGV)
