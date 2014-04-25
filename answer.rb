class Answer
  attr_reader :id, :text, :next
  def initialize(id, text, next_question = nil)
    @id = id
    @text = text
    @next = next_question
  end
end