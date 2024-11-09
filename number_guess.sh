#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo Enter your username:
read USERNAME

GET_USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

if [[ -z $GET_USERNAME_RESULT ]]
then
  ADD_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
  echo Welcome, $USERNAME! It looks like this is your first time here.
else
  GET_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME';")
  echo "$GET_STATS" | while IFS="|" read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
