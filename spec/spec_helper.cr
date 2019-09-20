TESTING = true

require "file_utils"
require "spec"
require "../src/wimpix"

def reset_tmp_dir
  FileUtils.rm_r("tmp")
  FileUtils.mkdir_p("tmp/wimpi_index_files")
end

def make_index
  env = Wimpix::Environment.new(CONFIG_FILE, false)
  idx = Wimpix::MdFmIndexer.new(env)
  idx.build_in_memory
  idx.write_to_disk
end
