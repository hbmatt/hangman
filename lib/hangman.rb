class Game
  def initialize
    @word = []
    @word_display_array = []
    @word_display = ''
    @strikes = 0
    @player = Player.new
  end

  def start_game
    puts "\n+------------------------------------------------+
    \rLet's Play Hangman!"

    choose_word()

    puts "\nThe secret word is #{@word.length} letters long.\n"
    make_board()

    until @strikes > 5 || @word == @word_display_array
      display_board()
      @player.guess_letter
      check_letter(@player.guess)
      update_board()
    end

    end_game()
  end

  def choose_word
    word_list = []
    dictionary = File.open('dictionary.txt', 'r')
    dictionary.readlines.each do |word|
      word = word.gsub("\r\n", '')
      word.length >= 5 && word.length <= 12 ? word_list.push(word) : next
    end
    @word = word_list.sample.split('')
  end

  def make_board
    @word_display_array = Array.new(@word.length, '_')
    @word_display = @word_display_array.join(' ')
  end

  def update_board
    @word_display = @word_display_array.join(' ')
  end

  def display_board
    puts "\n#{@word_display}  ||  Strikes: #{@strikes}  ||  Missed letters: #{@player.incorrect_letters.join(' ')}\n\n"
  end

  def check_letter(guess)
    if @word.include?(guess)
      add_letter(@player.guess)
    else
      strike_letter(@player.guess)
    end
  end

  def add_letter(guess)
    @player.correct_letters.push(@player.guess)
    @word_display_array.each_index do |i|
      if @word[i] == guess
        @word_display_array[i] = guess
      end
    end
  end

  def strike_letter(guess)
    @player.incorrect_letters.push(guess)
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
      Game.new.start_game
    else
      puts "\nGoodbye!"
      exit
    end
  end
end

class Player
  attr_accessor :guess, :incorrect_letters, :correct_letters

  def initialize
    @guess = []
    @incorrect_letters = []
    @correct_letters = []
  end

  def guess_letter
    puts "Guess a letter:"
    @guess = gets.chomp.downcase

    while @guess == "/[^a-z]/" || @guess.length > 1 || @incorrect_letters.include?(@guess)
      puts "\nYou can't do that! Guess a letter:"
      @guess = gets.chomp.downcase
    end
  end
end

Game.new.start_game
