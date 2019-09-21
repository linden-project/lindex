TESTING = true

require "file_utils"
require "spec"
require "../src/wimpix"

def full_make_index_cycle
  env = Wimpix::Environment.new(CONFIG_FILE, false)
  idx = Wimpix::MdFmIndexer.new(env)
  idx.clean_index_dir
  idx.build_in_memory
  idx.write_index_az
  idx.write_to_disk
end
