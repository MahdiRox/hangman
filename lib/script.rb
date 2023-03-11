require 'json'

class HangmanGame
  def initialize(words_filename)
    @words = File.read(words_filename).split
    @random_word = ""
    @tries = 20
    @user_answer = ""
  end

  def start
    puts "Welcome to the Hangman game!"
    puts "Press 1 to start a new game."
    puts "Press 2 to load a saved game."
    start_choice = gets.chomp.to_i

    case start_choice
    when 1
      select_random_word
      initialize_user_answer
      play_game
    when 2
      load_game
      play_game
    else
      puts "Goodbye!"
    end
  end

  private

  def select_random_word
    random_number = rand(@words.length)
    @random_word = @words[random_number]
  end

  def initialize_user_answer
    @user_answer = "_" * @random_word.length
  end

  def play_game
    loop do
      puts "Enter your guess (you have #{@tries} tries left) or type 'save' to save the game:"
      answer = gets.chomp.downcase

      if answer == 'save'
        save_game
        puts "Game saved!"
        break
      elsif answer.length != 1 || answer.match?(/\d/)
        puts "Sorry, that's an invalid answer. Please enter a single letter."
      else
        handle_valid_answer(answer)
      end

      if game_over?
        break
      end
    end
  end

  def handle_valid_answer(answer)
    if @random_word.include?(answer)
      if @user_answer.include?(answer)
        puts "Sorry, the letter '#{answer}' is already guessed"
        @tries -= 1
      else
        @random_word.chars.each_with_index do |char, index|
          @user_answer[index] = answer if char == answer
        end
        puts @user_answer
        puts "Nice! The letter '#{answer}' is in the word."
      end
    else
      puts @user_answer
      puts "Sorry, the letter '#{answer}' is not in the word"
      @tries -= 1
    end
  end

  def game_over?
    if @user_answer == @random_word
      puts "Congratulations, you guessed the word '#{@random_word}'!"
      return true
    end

    if @tries == 0
      puts "Sorry, you're out of tries. The word was '#{@random_word}'."
      return true
    end

    false
  end

  def save_game
    puts "Enter the name of the file to save:"
    filename = gets.chomp.strip
    game_state = {  random_word: @random_word, tries: @tries, user_answer: @user_answer }
    File.write("/home/mahdi/repos/hangman/save/#{filename}", game_state.to_json)
  end

  def load_game
    puts "Enter the name of the file to load:"
    filename = gets.chomp.strip
    game_state = JSON.parse(File.read("/home/mahdi/repos/hangman/save/#{filename}"))
    @random_word = game_state['random_word']
    @tries = game_state['tries']
    @user_answer = game_state['user_answer']
    puts "Game loaded!"
  end
end

game = HangmanGame.new("words.txt")
game.start
