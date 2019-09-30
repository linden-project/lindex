module Lindex
  VERSION = "0.1.6"

  class BuildInfo
    macro define_method(name, content)
      def self.{{name}}
        {"uname" => "{{`uname -a`}}", "crystal" => "{{`crystal -v`}}"}
      end
    end

    define_method(build_machine_info, "")
  end
end
