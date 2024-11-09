#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

GET_USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")

if [[ -z $GET_USERNAME_RESULT ]]
then
  ADD_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, NULL);")
  echo "Welcome, $( echo $USERNAME | sed -r 's/^ *| *$//g')! It looks like this is your first time here."
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
    echo You guessed it in $GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!
    UPDATE_STATS=$($PSQL "UPDATE users SET games_played = games_played + 1,
      best_game = CASE
        WHEN best_game IS NULL OR $GUESS < best_game THEN $GUESS
        ELSE best_game
      END WHERE username = '$USERNAME';")
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
