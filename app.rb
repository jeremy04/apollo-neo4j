require "./config"
require "sinatra"
require "pp"
require "sinatra/reloader" if development?

get "/" do
  #@first_question = Neography::Node.find("survey_index", "supply", "q1").text
  start_node = Neo4j::Label.find_all_nodes(:start_node).first
  @first_question =  start_node.node(dir: :outgoing, type: :first_question)
  @answers = @first_question.nodes(dir: :outgoing, type: :answer).map do |answer| answer[:text] end
  erb :index
end