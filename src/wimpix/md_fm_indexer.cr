require "ecr"

class Wimpix::MdFmIndexer
  getter env : Wimpix::Environment

  @idx_h_docs_errors = {} of String => String
  @idx_a_docs_starred = [] of String
  @idx_a_taxonomies_singular = [] of String
  @idx_h_docs_with_terms = Hash(String, Hash(String, String)).new
  @idx_h_docs_with_titles = Hash(String, String).new # DEPRICIATED

  def initialize(@env)

    @proc_current_yaml_level = 0
    @proc_current_markdown_file = ""

    @files = [] of String
    @files = validate_path_with_option(@env.wiki_dir)
  end

  def clean_index_dir
    d = Dir.new(@env.index_dir.to_s)
    d.each do |f|
      if f != "." && f != ".."
        FileUtils.rm @env.index_dir.join(f).to_s
      end
    end
  end

  def build_in_memory
    read_markdown_files_populate_memory_index
    read_taxonomies_from_conf_to_memory
  end

  def write_to_disk
    write_to_file(@env.index_dir.join("_index_keys.json"), @idx_a_taxonomies_singular.to_json)
    write_to_file(@env.index_dir.join("_index_docs_starred.json"), @idx_a_docs_starred.to_json)
    write_to_file(@env.index_dir.join("_index_docs_with_keys.json"), @idx_h_docs_with_terms.to_json)
    write_to_file(@env.index_dir.join("_index_docs_with_title.json"), @idx_h_docs_with_titles.to_json)
  end

  def read_taxonomies_from_conf_to_memory
    @env.index_conf.as_h["index_keys"].as_h.each do |index_key, index_val|
      @idx_a_taxonomies_singular << index_val.as_h["singular"].as_s
    end
  end

  def write_index_az
    write_to_file(@env.wiki_dir.join("index.md"), ECR.render "tpl/index.md.ecr")
  end

  private def read_markdown_files_populate_memory_index
    @files.each do |file|
      unless File.basename(file) == "index.md"
        begin
          index_file(file)
          if !@idx_h_docs_with_terms[File.basename(file)].has_key? "title"
            @idx_h_docs_with_terms[File.basename(file)]["title"] = filename_to_title(file)
          end
          @idx_h_docs_with_titles[File.basename(file)] = @idx_h_docs_with_terms[File.basename(file)]["title"]
        rescue
          p file + " could not process Front Matter."
        end
      end
    end
  end

  private def filename_to_title(filepath)
    File.basename(filepath, ".md").capitalize.gsub("_", " ")
  end

  private def index_file(file)
    front_matter_as_yaml_any = YAML::Any

    begin
      FrontMatter.open(file, false) do |front_matter, _|
        front_matter_as_yaml_any = YAML.parse front_matter
        @proc_current_yaml_level = 0
        @proc_current_markdown_file = File.basename(file)
        proc_yaml(front_matter_as_yaml_any, @proc_current_yaml_level)
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

  private def proc_yaml(node : YAML::Any, level : Int)
    case node.raw
    when String
      return YAML::Any.new(node.as_s)
    when Array(YAML::Any)
      new_node = [] of YAML::Any
      node.as_a.each do |value|
        new_node << proc_yaml(value, level + 1)
      end

      return YAML::Any.new(new_node)
    when Hash(YAML::Any, YAML::Any)
      new_node = {} of YAML::Any => YAML::Any
      node.as_h.each do |key, value|
        if level == 0
          proc_node_index_starred_document(key, value)
          proc_node_index_terms_in_document(key, value)
        end

        new_node[YAML::Any.new(key.as_s)] = proc_yaml(value, level + 1)
      end

      return YAML::Any.new(new_node)
    else
      return node
    end
  end

  private def proc_node_index_starred_document(key, value)
    if key.as_s == "starred" && value.as_bool
      @idx_a_docs_starred << @proc_current_markdown_file
    end
  end

  private def proc_node_index_terms_in_document(key, value)
    case value.raw
    when String
      if @idx_h_docs_with_terms.has_key? @proc_current_markdown_file
        @idx_h_docs_with_terms[@proc_current_markdown_file][key.as_s] = value.as_s
      else
        @idx_h_docs_with_terms[@proc_current_markdown_file] = {key.as_s => value.as_s}
      end
    end
  end

  private def write_to_file(out_file, contents)
    file_h = File.open out_file, "w"
    file_h.puts contents
    file_h.close
  end
end
