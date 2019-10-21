require "ecr"

class Lindex::MdFmIndexer
  getter env : Lindex::Environment

  @idx_h_docs_errors = {} of String => String
  @idx_a_docs_starred = [] of String
  @idx_a_terms_starred = Array(Hash(String, String)).new
  @idx_a_taxonomies_singular = [] of String
  @idx_h_docs_with_terms = Hash(String, Hash(String, YAML::Any)).new
  @idx_h_docs_with_titles = Hash(String, String).new # DEPRICIATED
  @idx_h_taxonomies_with_terms = Hash(String, Hash(String, Array(String))).new
  @idx_h_lindex_self_info = Hash(String, String).new

  def initialize(@env)
    @proc_current_yaml_level = 0
    @proc_current_markdown_file = ""

    build_machine_info
    lindex_self_info

    @files = [] of String
    @files = validate_path_with_option(@env.wiki_dir)
  end

  macro define_method(name, content)
    def {{name}}
      {"uname" => "{{`uname -a`}}", "crystal" => "{{`crystal -v`}}"}
    end
  end

  define_method(build_machine_info, "")

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
    write_taxonomy_terms_and_values_index_files
  end

  def lindex_self_info
    comp_info = build_machine_info["crystal"].split("\n")

    @idx_h_lindex_self_info["product_name"] = "Lindex"
    @idx_h_lindex_self_info["product_version"] = Lindex::VERSION
    @idx_h_lindex_self_info["build_machine"] = build_machine_info["uname"].gsub("\n", "")
    @idx_h_lindex_self_info["crystal_version"] = comp_info[0]
    @idx_h_lindex_self_info["llvm"] = comp_info[2]
    @idx_h_lindex_self_info["index_dir"] = @env.index_dir.to_s
    @idx_h_lindex_self_info["wiki_dir"] = @env.wiki_dir.to_s
    @idx_h_lindex_self_info["config_dir"] = @env.config_dir.to_s
  end

  def write_to_disk
    write_to_file(@env.index_dir.join("_index_taxonomies.json"), @idx_a_taxonomies_singular.to_json)
    write_to_file(@env.index_dir.join("_index_docs_starred.json"), @idx_a_docs_starred.to_json)
    write_to_file(@env.index_dir.join("_index_docs_with_props.json"), @idx_h_docs_with_terms.to_json)
    write_to_file(@env.index_dir.join("_index_docs_with_title.json"), @idx_h_docs_with_titles.to_json) # DEPRICIATED
    write_to_file(@env.index_dir.join("_index_terms_starred.json"), @idx_a_terms_starred.to_json)
    write_to_file(@env.index_dir.join("_indexer_info.json"), @idx_h_lindex_self_info.to_json)
  end

  def write_taxonomy_terms_and_values_index_files
    @env.index_conf.as_h["index_keys"].as_h.each do |index_key, index_val|
      # @idx_a_taxonomies_singular << index_val.as_h["singular"].as_s
      @idx_a_taxonomies_singular << index_key.as_s

      if index_val.as_h.has_key?("features") && index_val.as_h["features"].as_a.includes? "sub_index"
        index_key_vals_titles = Hash(String, YAML::Any).new

        if @idx_h_taxonomies_with_terms.has_key? index_key.as_s
          @idx_h_taxonomies_with_terms[index_key.as_s].each do |index_key_val, index_key_val_docs|
            index_key_vals_titles[index_key_val] = get_taxo_term_conf(index_key, index_key_val)

            if index_key_vals_titles[index_key_val].size > 0
              if index_key_vals_titles[index_key_val].as_h.has_key? "starred"
                @idx_a_terms_starred << {"taxonomy" => index_key.as_s, "term" => index_key_val}
              end
            end

            # write term index with values
            write_to_file(@env.l2_index_filepath(index_key, index_key_val), index_key_val_docs.to_json)
          end
        end
      end

      # # write taxonomy index with terms
      write_to_file(@env.l1_index_filepath(index_key), index_key_vals_titles.to_json)
    end
  end

  def add_value_to_term_in_taxonomy_idx(taxonomy, term, item)
    @idx_h_taxonomies_with_terms[taxonomy] = Hash(String, Array(String)).new unless @idx_h_taxonomies_with_terms.has_key? taxonomy
    @idx_h_taxonomies_with_terms[taxonomy][term.to_s.downcase] = [] of String unless @idx_h_taxonomies_with_terms[taxonomy].has_key? term.to_s.downcase
    @idx_h_taxonomies_with_terms[taxonomy][term.to_s.downcase] << item
  end

  def get_taxo_term_conf(tax, term)
    path = @env.config_dir.join("L2-CONF-TAX-#{tax}-TRM-#{term}.yml")

    if File.exists? path
      File.open(path) { |file| YAML.parse(file) }
    else
      YAML::Any.new({} of YAML::Any => YAML::Any)
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
            @idx_h_docs_with_terms[File.basename(file)]["title"] = YAML::Any.new(filename_to_title(file))
          end

          @idx_h_docs_with_titles[File.basename(file)] = @idx_h_docs_with_terms[File.basename(file)]["title"].as_s # DEPRICIATED

          add_value_to_term_in_taxonomy_idx "front_matter", "valid", @proc_current_markdown_file
          @idx_h_docs_with_terms[File.basename(file)]["front_matter"] = YAML::Any.new("valid")
        rescue
          # GEEN GELDIGE FRONTMATTER
          @idx_h_docs_with_terms[File.basename(file)] = {"title" => YAML::Any.new(filename_to_title(file))}

          @idx_h_docs_with_titles[File.basename(file)] = @idx_h_docs_with_terms[File.basename(file)]["title"].as_s # DEPRICIATED

          @idx_h_docs_with_terms[File.basename(file)]["front_matter"] = YAML::Any.new("invalid")
          add_value_to_term_in_taxonomy_idx "front_matter", "invalid", @proc_current_markdown_file
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

        @env.index_conf.as_h["index_keys"].as_h.keys.each do |index_key|
          if front_matter_as_yaml_any.as_h.has_key? index_key
            if @env.index_conf.as_h["index_keys"].as_h[index_key]["type"] == "has_many_belong_to_many"
              case front_matter_as_yaml_any.as_h[index_key].raw
              when Array(YAML::Any)
                front_matter_as_yaml_any.as_h[index_key].as_a.each do |single_val|
                  add_value_to_term_in_taxonomy_idx index_key.as_s, single_val, @proc_current_markdown_file
                end
              when Hash(YAML::Any, YAML::Any)
                # Do nothing
              else
                add_value_to_term_in_taxonomy_idx index_key.as_s, front_matter_as_yaml_any.as_h[index_key], @proc_current_markdown_file
              end
            elsif @env.index_conf.as_h["index_keys"].as_h[index_key]["type"] == "has_many"
              add_value_to_term_in_taxonomy_idx index_key.as_s, front_matter_as_yaml_any.as_h[index_key], @proc_current_markdown_file
            end
          end
        end
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
    when Bool
      return YAML::Any.new(node.raw)
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
    if @idx_h_docs_with_terms.has_key? @proc_current_markdown_file
      @idx_h_docs_with_terms[@proc_current_markdown_file][key.as_s] = value
    else
      @idx_h_docs_with_terms[@proc_current_markdown_file] = {key.as_s => value}
    end
  end

  private def write_to_file(out_file, contents)
    file_h = File.open out_file, "w"
    file_h.puts contents
    file_h.close
  end
end
