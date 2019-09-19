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
    reset_tmp_dir
    make_index

    starred_json = File.open(Path["tmp/wimpi_index_files/_index_docs_starred.json"].expand) { |file| JSON.parse(file) }
    starred_json.as_a.size.should eq 2
  end

  it "should create index and have valid _index_keys.json" do
    reset_tmp_dir
    make_index

    index_keys_json = File.open(Path["tmp/wimpi_index_files/_index_keys.json"].expand) { |file| JSON.parse(file) }
    index_keys_json.as_a.size.should eq 5
  end

end
