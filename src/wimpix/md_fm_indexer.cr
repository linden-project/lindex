class Wimpix::MdFmIndexer
  getter env : Wimpix::Environment

  # getter idx_h_docs_errors : {} of String => String
  # getter idx_h_docs_errors : Hash
  # getter idx_a_docs_starred : [] of String
  # getter idx_h_docs_with_keys : {} of String => {}
  # getter idx_a_fm_keys_found : [] of String
  # getter idx_a_fm_keys_conf : [] of String

  #getter proc_yaml_level = 0
  #getter proc_yaml_file = ""

  def initialize(@env)
    @idx_h_docs_errors = {} of String => String
    @idx_a_docs_starred = [] of String

    @idx_a_taxonomies_singular = [] of String

    @proc_yaml_level = 0
    @proc_yaml_file = ""

    @files = [] of String
    @files = validate_path_with_option(@env.wiki_dir)
  end

  def build_in_memory
    read_markdown_files_populate_memory_index
    read_taxonomies_from_conf_to_memory
  end

  def write_to_disk
    write_to_file(@env.index_dir.join("_index_keys.json"), @idx_a_taxonomies_singular.to_json)
    write_to_file(@env.index_dir.join("_index_docs_starred.json"), @idx_a_docs_starred.to_json)
  end


  def read_taxonomies_from_conf_to_memory
    @env.index_conf.as_h["index_keys"].as_h.each do |index_key, index_val|
      @idx_a_taxonomies_singular << index_val.as_h["singular"].as_s
    end
  end




  private def read_markdown_files_populate_memory_index
    @files.each do |file|
      begin
        index_file(file)
      rescue
        p file + " has invalid Front Matter."
      end
    end
  end

  private def index_file(file)
    front_matter_as_yaml_any = YAML::Any

    begin
      FrontMatter.open(file, false) do |front_matter, _|
        front_matter_as_yaml_any = YAML.parse front_matter
        @proc_yaml_level = 0
        @proc_yaml_file = file
        proc_yaml(front_matter_as_yaml_any)
      end
    rescue
      @idx_h_docs_errors[file] = "error in front matter"
    end
  end

  private def validate_path_with_option(path)
    if File.directory?(path)
      return Dir.glob(path.to_s + "/*.md")
    else
      raise path.to_s + " not a valid directory"
    end
  end

  private def proc_yaml(node : YAML::Any)
    case node.raw
    when String
      return YAML::Any.new(node.as_s)
    when Array(YAML::Any)
      new_node = [] of YAML::Any
      node.as_a.each do |value|
        new_node << proc_yaml(value)
      end
      return YAML::Any.new(new_node)
    when Hash(YAML::Any, YAML::Any)
      new_node = {} of YAML::Any => YAML::Any
      node.as_h.each do |key, value|

        if @proc_yaml_level == 0
          proc_node_index_starred_document(key, value)
        end

        new_node[YAML::Any.new(key.as_s)] = proc_yaml(value)
      end
      return YAML::Any.new(new_node)
    else
      return node
    end

    node
  end

    private def proc_node_index_starred_document(key, value)
      if key.as_s == "starred" && value.as_bool
        @idx_a_docs_starred << @proc_yaml_file
      end
    end


  private def write_to_file(out_file, contents)
    file_h = File.open out_file, "w"
    file_h.puts contents
    file_h.close
  end
end
