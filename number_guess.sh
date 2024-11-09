#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo Enter your username:
read USERNAME

GET_USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

if [[ -z $GET_USERNAME_RESULT ]]
then
  ADD_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
  echo Welcome, $( echo $USERNAME | sed -r 's/^ *| *$//g')! It looks like this is your first time here.
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
  echo "Welcome back, $( echo $USERNAME | sed -r 's/^ *| *$//g')! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi


GUESS_NUMBER() {
  if [[ -z $GUESS ]]
  then
    GUESS=1
  fi

  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  if [[ $1 ]]
  then
    echo $1
  else
    echo Guess the secret number between 1 and 1000:
  fi
    read USER_GUESS
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
     GUESS_NUMBER "That is not an integer, guess again:"
     return
    fi
    if [[ $USER_GUESS -eq $RANDOM_NUMBER ]]
    then
      echo You guessed it in $GUESS tries. The secret number was $RANDOM_NUMBER! Nice job!
      if [[ -z $BEST_GAME ]]
      then
        INSERT_FIRST_GAME=$($PSQL "UPDATE users SET games_played = 1, best_game = $GUESS WHERE username = '$USERNAME'")
      else
        UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
        if [[ $GUESS -lt $BEST_GAME ]]
        then
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESS WHERE username = '$USERNAME';")
        fi
      fi
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