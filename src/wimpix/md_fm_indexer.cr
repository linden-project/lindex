class Wimpix::MdFmIndexer

  getter env : Wimpix::Environment

  #getter idx_h_docs_errors : {} of String => String
#  getter idx_h_docs_errors : Hash
#  getter idx_a_docs_starred : [] of String
#  getter idx_h_docs_with_keys : {} of String => {}
#  getter idx_a_fm_keys_found : [] of String
#  getter idx_a_fm_keys_conf : [] of String

#  getter files : Array

  def initialize(@env)

    @idx_h_docs_errors = {} of String => String
    @files = [] of String
    @files = validate_path_with_option(@env.wiki_dir)
    read_files_populate_memory_index
  end

  def validate_path_with_option(path)
    if File.directory?(path)
      return Dir.glob(path.to_s + "/*.md")
    else
      raise path.to_s + " not a valid directory"
    end
  end


  def read_files_populate_memory_index
    @files.each do |file|
      begin
        index_file(file)
      rescue
        p file + " has invalid Front Matter."
      end
    end
  end

  def index_file(file)

    front_matter_as_yaml_any = YAML::Any

    begin
      FrontMatter.open(file, false) do |front_matter, _|
        front_matter_as_yaml_any = YAML.parse front_matter
      end

      pp front_matter_as_yaml_any

    rescue
      @idx_h_docs_errors[file] = "error in front matter"
    end
  end

end

