require "./config"
require "./survey"
require "./question"
require "./answer"
require "./predicate"
require "debugger"
require "pp"

def neo_obj
  NEO_DB
end


neo_obj.query("MATCH (n)
 OPTIONAL MATCH (n)-[r]-()
 DELETE n,r")


def create_questions(questions, current_questions, survey_id, start_node)
  question_label = Neo4j::Label.create(:question)
  question_label.create_index(:id)

  questions.each do |question|
    if not current_questions.map { |q| q.id }.include?(question.id)
      new_question = Neo4j::Node.create({id: question.id, text: question.text}, :question )
      Neo4j::Relationship.create(:question, start_node, new_question)
    end
  end

end


def create_predicates(questions, survey_id)
  predicate_label = Neo4j::Label.create(:predicate)
  predicate_label.create_index(:id)

  questions.each do |question|
    if question.predicate # if not at the end of survey (last question has no predicate)

      question_node = Neo4j::Label.query(:question, conditions: {id: question.id}).first
      new_predicate_node = Neo4j::Node.create({id: question.predicate.id }, :predicate)
      Neo4j::Relationship.create(:predicate, question_node, new_predicate_node)

      next_question_true = question.predicate.true_result # next question id
      next_question_false = question.predicate.false_result # next question id

      if next_question_true # if not at the end of survey
        #next_question_node = Neo4j::Label.find_all_nodes(next_question_true.to_sym).first
        next_question_node = Neo4j::Label.query(:question, conditions: {id: next_question_true}).first
        Neo4j::Relationship.create(:true, new_predicate_node, next_question_node)
      end

      if next_question_false # if not at the end of survey
        next_question_node = Neo4j::Label.query(:question, conditions: {id: next_question_false}).first
        Neo4j::Relationship.create(:false, new_predicate_node, next_question_node)
      end

    end
  end
end


def create_answers(questions, survey_id)
  answer_label = Neo4j::Label.create(:predicate)
  answer_label.create_index(:id)

  questions.each do |question|
    # create answers

    question_node = Neo4j::Label.query(:question, conditions: {id: question.id}).first
    question.answers.each do |answer|
      answer_node = Neo4j::Node.create({ id: answer.id, text: answer.text}, :answer)
      Neo4j::Relationship.create(:answer, question_node, answer_node)
    end
  end
end


# Configure here!!!

def build_predicates(hash)
  hash["new_mask"].predicate = Predicate.build(next_question: hash["new_headgear"].id)
  hash["new_headgear"].predicate = Predicate.build(next_question: hash["new_tubing"].id)
  hash["new_tubing"].predicate = Predicate.build(id: "no_supply_predicate", true_result: hash["order_confirm"].id, false_result: nil )
  hash.map { |h| h[1] }
end


def awesome_survey
  surveys = [Survey.new("supply", "Supply Survey", "A survey about supplies")]
  survey = surveys.first
  start_node = Neo4j::Node.create({id: survey.id, title: survey.title, description: survey.description}, "start_node")

  survey_id = "supply"
  
  q1_answers = [Answer.new('mask_yes','yes'), Answer.new('mask_no','no')]
  q1 = Question.new('new_mask','Do you need a new mask?', q1_answers)

  q2_answers = [Answer.new('headgear_yes','yes'), Answer.new('headgear_no','no')]
  q2 = Question.new('new_headgear','Do you need a new headgear?', q2_answers)

  q3_answers = [Answer.new('tubing_yes','yes'), Answer.new('tubing_no','no')]
  q3 = Question.new('new_tubing','Do you need new tubing?', q3_answers)

  q4_answers = [Answer.new('order_confirm_yes','yes'), Answer.new('order_confirm_no','no')]
  q4 = Question.new('order_confirm','Are you sure you will like to order supplies?', q4_answers) 

  questions = [q1, q2, q3, q4]

  current_questions = start_node.nodes(dir: :outgoing, type: :question)

  question_mapping = Hash[questions.map { |q| [q.id, q] }]

  questions = build_predicates(question_mapping)

  create_questions(questions, current_questions, survey_id, start_node)
  create_answers(questions, survey_id)
  create_predicates(questions, survey_id)

  first_question = Neo4j::Label.query(:question, conditions: {id: q1.id}).first
  Neo4j::Relationship.create(:first_question, start_node, first_question)
  
end

awesome_survey