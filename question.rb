# Dont store answers, store predicates because everything has predicates
class Question
  attr_reader :id, :text, :answers
  def initialize(id, text, answers)
    @id = id
    @text = text
    @answers = answers
  end

end