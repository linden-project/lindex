require "./spec_helper"
CONFIG_FILE = "spec/wimpi_sysconfig/wimpi.yml"

describe Wimpix do
  it "should print VERSION" do
    puts Wimpix::VERSION
  end

  it "should setup environment" do
    env = Wimpix::Environment.new(CONFIG_FILE, false)

    env.file_name_to_wiki_link("this_is_a_regular_wiki_item").should eq("[[This is a regular wiki item]]")
    env.index_conf.class.should eq YAML::Any

    env.l2_index_filepath("project").should eq(Path["tmp/wimpi_index_files/L2-INDEX_TRM_project.json"].expand)
    env.l3_index_filepath("project", "wimpix development").should eq(Path["tmp/wimpi_index_files/L3-INDEX_TRM_project_VAL_wimpix development.json"].expand)
  end

  it "should create index and have valid _index_docs_starred.json" do
    full_make_index_cycle

    starred_json = File.open(Path["tmp/wimpi_index_files/_index_docs_starred.json"].expand) { |file| JSON.parse(file) }
    starred_json.as_a.size.should eq 2
  end

  it "should create index and have valid _index_keys.json" do
    full_make_index_cycle

    index_keys_json = File.open(Path["tmp/wimpi_index_files/_index_keys.json"].expand) { |file| JSON.parse(file) }
    index_keys_json.as_a.size.should eq 5
  end

  it "should create index and have valid _index_docs_with_keys.json" do
    env = Wimpix::Environment.new(CONFIG_FILE, false)
    full_make_index_cycle

    index_docs_with_terms = File.open(Path["tmp/wimpi_index_files/_index_docs_with_keys.json"].expand) { |file| JSON.parse(file) }
    index_docs_with_terms.as_h.size.should eq 4
    index_docs_with_terms.as_h.each do |k, v|
      File.exists?(env.wiki_dir.join(k)).should be_true
      (v.as_h["title"].as_s != "").should be_true
    end
  end

  it "should create index and have valid _index_docs_with_title.json" do
    env = Wimpix::Environment.new(CONFIG_FILE, false)
    full_make_index_cycle

    index_docs = File.open(Path["tmp/wimpi_index_files/_index_docs_with_title.json"].expand) { |file| JSON.parse(file) }
    index_docs.as_h.size.should eq 4
    index_docs.as_h.each do |k, v|
      File.exists?(env.wiki_dir.join(k)).should be_true
      (v.as_s != "").should be_true
    end
  end

  it "should delete all files in index_dir" do
    env = Wimpix::Environment.new(CONFIG_FILE, false)
    idx = Wimpix::MdFmIndexer.new(env)
    idx.clean_index_dir
    idx.build_in_memory
    idx.write_to_disk

    d = Dir.new(env.index_dir.to_s)
    (d.size > 2).should be_true

    d = Dir.new(env.index_dir.to_s)

    idx.clean_index_dir
    d = Dir.new(env.index_dir.to_s)
    d.size.should eq 2

  end

end
