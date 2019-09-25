TESTING = true

require "file_utils"
require "spec"
require "../src/lindex"

def make_tmp_dirs
  env = Lindex::Environment.new(CONFIG_FILE, false)
  FileUtils.mkdir_p env.index_dir.to_s
end

def full_make_index_cycle
  env = Lindex::Environment.new(CONFIG_FILE, false)
  idx = Lindex::MdFmIndexer.new(env)
  idx.clean_index_dir
  idx.build_in_memory
  idx.write_index_az
  idx.write_to_disk
end

make_tmp_dirs
