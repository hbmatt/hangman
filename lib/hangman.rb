require 'yaml'

module SaveLoad
  def save_game(word, word_display_array, word_display, strikes, incorrect_letters)
    saved_variables = [word, word_display_array, word_display, strikes, incorrect_letters]

    data = { 'word' => word, 'word_display_array' => word_display_array, 'word_display' => word_display, 'strikes' => strikes, 'incorrect_letters' => incorrect_letters}

    File.open('save.yaml', 'w') do |file|
      file.write(data.to_yaml)
    end

    puts "\nYour game has been saved.\n"

    exit_game()
  end

  def exit_game
    puts "\nKeep playing? [Y/N]"

    answer = gets.chomp.upcase

    until answer == "Y" || answer == "N"
      puts "\nYou can't do that! Keep playing? [Y/N]"
      answer = gets.chomp.upcase
    end

    if answer == "N"
      puts "\nGoodbye!"
      exit
    end
  end

  def load_file
    if File.exist?('save.yaml')
      YAML.load(File.read('save.yaml'))
    else
      puts "\n\nThere is no save information."
      puts "\n\nStarting new game!\n\n"
    end
  end
end

class Game
  include SaveLoad
  attr_accessor :word, :word_display_array, :word_display, :strikes, :incorrect_letters

  def initialize
    @word = []
    @word_display_array = []
    @word_display = ''
    @strikes = 0
    @incorrect_letters = []
    @player = Player.new
  end

  def play_game
    puts "\n+------------------------------------------------+
    \rLet's Play Hangman!"

    choose_word()
    make_board()
    ask_load()

    puts "\nThe secret word is #{@word.length} letters long.
    \rTo save the game at any point, type 'save'.\n\n"


    until @strikes > 5 || @word == @word_display_array
      update_board()
      display_board() 
      @player.guess_letter(@incorrect_letters)
      check_save()
      check_letter(@player.guess)
    end

    end_game()
  end

  def ask_load
    puts "\nLoad saved game? [Y/N]"
    answer = gets.chomp.upcase

    until answer == "Y" || answer == "N"
      puts "\nYou can't do that! Load game? [Y/N]"
      answer = gets.chomp.upcase
    end

    if answer == "Y"
      load_game()
    else
      puts "\n\nStarting new game!\n\n"
    end 
  end

  def load_game()
    load = load_file()
    @word = load['word']
    @word_display_array = load['word_display_array']
    @word_display = load['word_display']
    @strikes = load['strikes']
    @incorrect_letters = load['incorrect_letters']
    
    puts "\n\nYour game has been loaded."
  end

  def check_save()
    if @player.guess == 'save'
      save_game(@word, @word_display_array, @word_display, @strikes, @incorrect_letters)
    end
  end

  def choose_word
    word_list = []
    dictionary = File.open('dictionary.txt', 'r')
    dictionary.readlines.each do |word|
      word = word.gsub("\r\n", '')
      word.length >= 5 && word.length <= 12 ? word_list.push(word) : next
    end
    @word = word_list.sample.downcase.split('')
  end

  def make_board
    @word_display_array = Array.new(@word.length, '_')
    @word_display = @word_display_array.join(' ')
  end

  def update_board
    @word_display = @word_display_array.join(' ')
  end

  def display_board
    puts "\n+------------------------------------------------+\n
    \r#{@word_display}  ||  Strikes: #{@strikes}  ||  Missed letters: #{@incorrect_letters.join(' ')}\n"
  end

  def check_letter(guess)
    if @word.include?(guess)
      add_letter(@player.guess)
    elsif guess == 'save'
      return
    else
      strike_letter(@player.guess)
    end
  end

  def add_letter(guess)
    @word_display_array.each_index do |i|
      if @word[i] == guess
        @word_display_array[i] = guess
      end
    end
  end

  def strike_letter(guess)
    @incorrect_letters.push(guess)
    @strikes += 1
  end

  def end_game
    if @strikes == 6
      puts "\nGame over! The word was #{@word.join('')}. The computer wins!"
    elsif @word_display_array == @word
      puts "\nGame over! The word was #{@word.join('')}. You win!"
    end

    restart()
  end

  def restart
    puts "\nPlay again? [Y/N]"
    answer = gets.chomp.upcase

    until answer == "Y" || answer == "N"
      puts "\nYou can't do that! Play again? [Y/N]"
      answer = gets.chomp.upcase
    end

    if answer == "Y"
      Game.new.play_game
    else
      puts "\nGoodbye!"
      exit
    end
  end
end

class Player
  include SaveLoad
  attr_accessor :guess

  def initialize
    @guess = []
  end

  def guess_letter(incorrect_letters)
    puts "\nGuess a letter:"
    @guess = gets.chomp.downcase

    unless @guess == 'save' || @guess == "/[a-z]/" || @guess.length == 1 || !incorrect_letters.include?(@guess)
      puts "\nYou can't do that! Guess a letter:"
      @guess = gets.chomp.downcase
    end
  end
end


Game.new.play_game
