#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=num_guess_game -t --no-align -c"

SECRET_NUM=$(echo $RANDOM)

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")


# if user is new
if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, 0)")

else
  GAMES_PLAYED=$(echo $USER_INFO | cut -d '|' -f 1 | xargs)
  BEST_GAME=$(echo $USER_INFO | cut -d '|' -f 2 | xargs)
  echo $GAMES_PLAYED and $BEST_GAME
fi

#insert user
