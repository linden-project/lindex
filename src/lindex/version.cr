module Lindex
  VERSION = "0.1.7"

  class BuildInfo
    macro define_method(name, content)
      def self.{{name}}
        {"uname" => "{{`uname -a`}}", "crystal" => "{{`crystal -v`}}"}
      end
    end

    define_method(build_machine_info, "")
  end
end
