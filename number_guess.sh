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

GUESS_NUMBER() {
  if [[ -z $GUESS ]]
  then
    GUESS=1
  fi

  if [[ $1 ]]
  then
    echo $1
  else
    echo Guess the secret number between 1 to 1000:
  fi
    read USER_GUESS
    if [[ $USER_GUESS -eq $RANDOM_NUMBER ]]
    then
      echo You guessed it in $GUESS tries. The secret number was $RANDOM_NUMBER!. Nice job!
    elif [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
    then
      ((GUESS++))
      GUESS_NUMBER "It's lower than that, guess again:"
    elif [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
    then
      ((GUESS++))
      GUESS_NUMBER "It's higher than that, guess again:"
    fi
}

GUESS_NUMBER