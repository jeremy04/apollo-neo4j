require "./config"
require "sinatra"
require "pp"
require "./predicate"
require "debugger"
require "sinatra/reloader" if development?

get "/" do
  "Welcome to Survey Hell"
end

get "/survey/:survey" do |survey|
  @survey_node = Neo4j::Label.find_all_nodes(survey.to_sym).first
  if @survey_node && @survey_node.node(dir: :outgoing, type: :current)
    @current_question = @survey_node.node(dir: :outgoing, type: :current)
    @has_previous_question = @current_question.nodes(dir: :outgoing, type: :previous).first
    @answers = @current_question.nodes(dir: :outgoing, type: :answer).map do |answer| answer[:text] end
  else
    redirect "/end"
  end
  erb :question
end

post "/survey/:survey" do |survey|
  survey_node = Neo4j::Label.find_all_nodes(survey.to_sym).first
  current_question =  survey_node.node(dir: :outgoing, type: :current)
  if params[:previous]
    previous_question = current_question.node(dir: :outgoing, type: :previous)
    move_to_question(survey_node, previous_question)
  else
    given_answer = params[current_question[:id].to_sym]
    final_answer = current_question.nodes(dir: :outgoing, type: :answer).select { |answer| answer[:text] == given_answer }.first
    # Insert possible answer into SR DB 'table'
    
    if given_answer #is the given answer valid???
      answer_hash = { current_question[:id].to_sym => given_answer }
      survey_node.update_props(answer_hash)
    end

    # Set current equal to next question
    #survey_node.rel(dir: :outgoing, type: :current).del

    if next_question = get_next_question(current_question, survey_node)
      move_to_question(survey_node, next_question)
    end
  end
  
  redirect "/survey/#{survey}"
end

def get_next_question(current_question, survey_node)
  predicate_node = current_question.nodes(dir: :outgoing, type: :predicate).first
  next_question = PredicateEvaluator.evaluate(predicate_node, survey_node) if predicate_node # No predicate means end of survey
end

def move_to_question(survey_node, question)
  survey_node.rel(dir: :outgoing, type: :current).del
  Neo4j::Relationship.create(:current, survey_node, question)
end

get "/end" do
  "Survey is over thank you. Please have a nice day"
end