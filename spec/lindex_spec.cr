require "./spec_helper"
CONFIG_FILE = "spec/lindex_sysconfig/lindex.yml"

describe Lindex do
  it "should print VERSION" do
    puts Lindex::VERSION
  end

  it "should setup environment" do
    env = Lindex::Environment.new(CONFIG_FILE, false)

    env.file_name_to_wiki_link("this_is_a_regular_wiki_item").should eq("[[This is a regular wiki item]]")
    env.index_conf.class.should eq YAML::Any

    env.l1_index_filepath("project").should eq(Path["tmp/index_files/L1-INDEX-TAX-project.json"].expand)
    env.l2_index_filepath("project", "lindex development").should eq(Path["tmp/index_files/L2-INDEX-TAX-project-TRM-lindex development.json"].expand)
  end

  it "should create index and have valid _index_docs_starred.json" do
    full_make_index_cycle

    starred_json = File.open(Path["tmp/index_files/_index_docs_starred.json"].expand) { |file| JSON.parse(file) }
    starred_json.as_a.size.should eq 2
  end

  it "should create index and have valid _index_taxonomies" do
    full_make_index_cycle

    index_keys_json = File.open(Path["tmp/index_files/_index_taxonomies.json"].expand) { |file| JSON.parse(file) }
    index_keys_json.as_a.size.should eq 6
  end

  it "should create index and have valid _index_docs_with_props" do
    env = Lindex::Environment.new(CONFIG_FILE, false)
    full_make_index_cycle

    index_docs_with_terms = File.open(Path["tmp/index_files/_index_docs_with_props.json"].expand) { |file| JSON.parse(file) }
    index_docs_with_terms.as_h.size.should eq 6
    index_docs_with_terms.as_h.each do |k, v|
      File.exists?(env.wiki_dir.join(k)).should be_true
      v.as_h["title"].as_s.should_not eq ""
    end
  end

  it "should create index and have valid _index_docs_with_title.json" do
    env = Lindex::Environment.new(CONFIG_FILE, false)
    full_make_index_cycle

    index_docs = File.open(Path["tmp/index_files/_index_docs_with_title.json"].expand) { |file| JSON.parse(file) }
    index_docs.as_h.size.should eq 6
    index_docs.as_h.each do |k, v|
      File.exists?(env.wiki_dir.join(k)).should be_true
      v.as_s.should_not eq ""
    end
  end

  it "should delete all files in index_dir" do
    env = Lindex::Environment.new(CONFIG_FILE, false)
    idx = Lindex::MdFmIndexer.new(env)
    idx.clean_index_dir
    idx.build_in_memory
    idx.write_to_disk

    d = Dir.new(env.index_dir.to_s)
    more_than_2 = d.size > 2
    more_than_2.should be_true

    idx.clean_index_dir
    d = Dir.new(env.index_dir.to_s)
    d.size.should eq 2
  end

  it "should create a index.md file" do
    env = Lindex::Environment.new(CONFIG_FILE, false)
    FileUtils.rm env.wiki_dir.join("index.md").to_s if File.exists? env.wiki_dir.join("index.md")
    idx = Lindex::MdFmIndexer.new(env)
    idx.build_in_memory
    idx.write_index_az

    content = File.read(env.wiki_dir.join("index.md"))
    include_butterfly = content.includes? "- [[Butterfly]]"
    include_butterfly.should be_true

    include_umbrella = content.includes? "- [[Umbrella with no front matter title]]"
    include_umbrella.should be_true
  end

  it "should create l2 index files" do
    env = Lindex::Environment.new(CONFIG_FILE, false)
    full_make_index_cycle
  end
end
