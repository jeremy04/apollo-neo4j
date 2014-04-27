class Predicate
  attr_reader :id, :true_result, :false_result

  def initialize(id, true_result, false_result)
    @id = id
    @true_result = true_result
    @false_result = false_result
  end

  def self.build(attrs)
    if attrs[:id]
      Predicate.new(attrs[:id], attrs[:true_result], attrs[:false_result])
    else
      true_result = attrs[:true_result] || attrs[:next_question]
      Predicate.new("no_predicate", true_result, true_result)
    end
  end

end

class NoSupplyPredicate
  def initialize
  end

  def execute(survey_node)
    survey_node.props.any? { |k,v| v == 'yes'}
  end
end

class NoPredicate
  def initialize
  end

  def execute(session)
    false
  end
end


class PredicateEvaluator
  def self.evaluate(node, session)
    pred_class = Kernel.const_get(node[:id].split("_").map { |x| x.capitalize }.join(""))
    true_question = node.nodes(dir: :outgoing, type: :true).first
    false_question = node.nodes(dir: :outgoing, type: :false).first
    pred_class.new.execute(session) ? true_question : false_question
  end
end