class Answer
  attr_reader :id, :text, :next
  def initialize(id, text, next_answer = nil)
    @id = id
    @text = text
    @next = next_answer
  end
end