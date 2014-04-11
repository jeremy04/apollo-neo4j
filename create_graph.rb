require "./config"
require "./survey"
require "./question"
require "./answer"
require "pp"

def neo_obj
 @neo ||= Neography::Rest.new
end

 neo_obj.execute_query(
   "MATCH (n)
 OPTIONAL MATCH (n)-[r]-()
 DELETE n,r")


def remap_questions(questions, current_questions, survey_id, start_node)

  questions.each do |question|
    if not current_questions.map { |q| q.id }.include?(question.id)
      new_question = Neography::Node.create("id" => question.id, "text" => question.text)
      Neography::Relationship.create(:question, start_node, new_question)
      new_question.add_to_index("survey_index", survey_id, question.id)
    end
  end

end

def create_answers(questions, survey_id)
   questions.each do |question|
    question_node = Neography::Node.find("survey_index", survey_id, question.id)
    question.answers.each do |answer|
      answer_node = Neography::Node.create("id" => answer.id, "text" => answer.text)

      Neography::Relationship.create(:answer, question_node, answer_node)
      if answer.next
        next_question = Neography::Node.find("survey_index", survey_id, answer.next)
        Neography::Relationship.create(:next, question_node, next_question)
      end
    end
  end
end


def awesome_survey
  surveys = [Survey.new("supply", "Supply Survey", "A survey about supplies")]
  survey = surveys.first
  start_node = Neography::Node.create("id" => survey.id, "title" => survey.title, "description" => survey.description)
  neo_obj.add_label(start_node, "start_node")

  survey_id = "supply"

  q1_answers = [Answer.new('q1a1','yes','q2'), Answer.new('q1a2','no')]

  #predicates = [ PredicateEligibleHeadgear.new(q2, q3) ]
  #q2 = Question.new('q2','Do you need a new headgear?', predicates)
  # during survey, inject answer into predicate

  q1 = Question.new('q1','Do you need a new mask?', q1_answers)
  
  q2_answers = [Answer.new('q2a1','yes','q3'), Answer.new('q2a2','no','q3')]
  
  q2 = Question.new('q2','Do you need a new headgear?', q2_answers)
  
  q3_answers = [Answer.new('q3a1','yes'), Answer.new('q3a2','no')]
  q3 = Question.new('q3','Do you need new tubing?', q3_answers)


  questions = [q1, q2, q3]
  current_questions = start_node.outgoing(:question)


  remap_questions(questions, current_questions, survey_id, start_node)
  create_answers(questions, survey_id)

  # Creates the 'first' relationship for the 'start'

  if start_node.outgoing(:first_question).size == 0
    first_question = Neography::Node.find("survey_index", survey_id, q1.id)
    Neography::Relationship.create(:first_question, start_node, first_question)
  end

  
end

awesome_survey