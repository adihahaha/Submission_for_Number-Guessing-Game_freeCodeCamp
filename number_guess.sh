#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=num_guess_game -t --no-align -c"

# generate random number
SECRET_NUM=$(echo $(( $RANDOM / 1000 + 1 )) )


# input username
echo "Enter your username:"
read USERNAME

# get user info
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")


# if user doesn't exist
if [[ -z $USER_INFO ]]
then
  #insert user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, 0)")

  #set best_game as zero for new user
  BEST_GAMES=0

# if user exists
else

  # set games_played and best_game
  GAMES_PLAYED=$(echo $USER_INFO | cut -d '|' -f 1 | xargs)
  BEST_GAME=$(echo $USER_INFO | cut -d '|' -f 2 | xargs)
  echo $GAMES_PLAYED and $BEST_GAME

  # welcome message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# initialize guesses to 0
GUESSES=0

# ask for guessing
echo "Guess the secret number between 1 and 1000:"

GUESSING() {
  

  read NUM

  # if guess is not a number
  if [[ ! $NUM =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read NUM

  else
    
    # if it is not a right guess

    while [[ ! $NUM -eq $SECRET_NUM ]]
    do
      if [[ $NUM -gt $SECRET_NUM ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi

      #increment guess by one for each try

      let GUESSES=GUESSES+1
      
      # recursion back to restart, for wrong guess
      GUESSING
    done
  fi

  # increse guess by 1, for final correct guess
  let GUESSES=GUESSES+1

  # increment games_played by one
  UPDATE_TRIAL=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")

  # if better than last time
  if [[ $GUESSES -lt $BEST_GAME ]]
  then

    # update best_game

    UPDATE_PERF=$($PSQL "UPDATE users SET best_game=$GUESSES")
  fi

  echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUM. Nice job!"

  exit
}

GUESSING