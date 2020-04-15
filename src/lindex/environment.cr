class Lindex::Environment
  getter main_config_file : String
  getter verbose : Bool

  getter index_dir : Path
  getter wiki_dir : Path
  getter config_dir : Path
  getter index_conf : YAML::Any

  def initialize(@main_config_file, @verbose)
    filename = Path[@main_config_file].expand(home: true)

    raise "FATAL L0 ROOT CONF: #{filename}" unless File.exists?(filename)

    main_conf = File.open(filename) { |file| YAML.parse(file) }
    pp main_conf if @verbose

    @index_dir = Path[main_conf["index_files_path"].as_s].expand(home: true)
    @wiki_dir = Path[main_conf["root_path"].as_s, "wiki"].expand(home: true)
    @config_dir = Path[main_conf["root_path"].as_s, "config"].expand(home: true)

    @index_conf = File.open(@config_dir.join("L0-CONF-ROOT.yml")) do |file|
      YAML.parse(file)
    end

    pp @index_conf if @verbose
  end

  def file_name_to_wiki_link(item)
    "[[#{File.basename(item, ".md").capitalize.gsub("_", " ")}]]"
  end

  def l1_index_filepath(tax)
    @index_dir.join "L1-INDEX-TAX-#{tax}.json"
  end

  def l2_index_filepath(tax, term)
    @index_dir.join "L2-INDEX-TAX-#{tax}-TRM-#{term}.json"
  end
end
