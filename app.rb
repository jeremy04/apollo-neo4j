require "./config"
require "sinatra"
require "pp"
require "sinatra/reloader" if development?

get "/" do
  "Welcome to Survey Hell"
end

get "/sessions/:session" do |session|
  session = Neo4j::Label.find_all_nodes(session.to_sym).first
  @first_question =  session.node(dir: :outgoing, type: :current)
  if @first_question.nil?
    redirect "/end"
  end
  @answers = @first_question.nodes(dir: :outgoing, type: :answer).map do |answer| answer[:text] end
  erb :question
end

post "/sessions/:session" do |session|
  session = Neo4j::Label.find_all_nodes(session.to_sym).first
  current_question =  session.node(dir: :outgoing, type: :current)
  given_answer = params[current_question[:id].to_sym]
  final_answer = current_question.nodes(dir: :outgoing, type: :answer).select { |answer| answer[:text] == given_answer }
  # Insert possible answer into DB
  
  #Delete current
  session.rel(dir: :outgoing, type: :current).del

  next_question = get_next_question(final_answer.first)

  # Set current equal to next question
  if next_question
    Neo4j::Relationship.create(:current, session, next_question)
  end
  redirect "/sessions/#{session[:id]}"
end

def get_next_question(answer)
  next_question = answer.node(dir: :outgoing, type: :next)
end

get "/end" do
  "Survey is over thank you. Please have a nice day"
end