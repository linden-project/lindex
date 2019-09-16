require "./spec_helper"

describe Wimpix do
  it "should print VERSION" do
    puts Wimpix::VERSION
  end

  it "should setup environment" do
    env = Wimpix::Environment.new(false)
    env.file_name_to_wiki_link("this_is_a_regular_wiki_item").should eq("[[This is a regular wiki item]]")
    env.index_conf.class.should eq YAML::Any
    env.l2_index_filepath("project").should eq(Path["~/.wimpi_index_files/L2-INDEX_TRM_project.json"].expand)
    env.l3_index_filepath("project", "wimpix development").should eq( Path["~/.wimpi_index_files/L3-INDEX_TRM_project_VAL_wimpix development.json"].expand)
  end
end
