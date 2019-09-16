class Wimpix::Environment

  #getter wimpi_root : Path
  getter index_dir : Path
  #getter index_conf_file : Path
  getter wiki_dir : Path

  getter index_conf : YAML::Any

  def initialize(verbose)

    file = "~/.wimpi/wimpi.yml"
    filename = Path[file].expand

    raise "FATAL 1ST CONF: #{filename}" unless File.exists?(filename)

    main_conf = File.open(filename) { |file| YAML.parse(file) }
    wimpi_root = Path[main_conf["root_path"].as_s].expand

    @index_dir = Path[main_conf["index_files_path"].as_s].expand
    @wiki_dir = Path[main_conf["root_path"].as_s,"wiki"].expand

    index_conf_file = Path[main_conf["root_path"].as_s,"config","wiki_indexes.yml"].expand
    @index_conf = File.open(index_conf_file) { |file| YAML.parse(file) }

    pp @index_conf if verbose

  end

  def dump_data
    pp @data
  end

  def dump_config
    pp @conf
  end

  def file_name_to_wiki_link(item)
    "[[#{File.basename(item,".md").capitalize.gsub("_", " ")}]]"
  end

  def l2_index_filepath(term)
    @index_dir.join "L2-INDEX_TRM_#{term}.json"
  end

  def l3_index_filepath(term, value)
    @index_dir.join "L3-INDEX_TRM_#{term}_VAL_#{value}.json"
  end

end
