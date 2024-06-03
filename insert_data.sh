#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#Line below to empty the tables, so we can rerun the script
echo $($PSQL "TRUNCATE TABLE teams, games")

#Line below is a while loop to go through every line of the games.csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #echo $OPPONENT
  #Line below is a check using if [[ $YEAR != 'year' ]]. This skips the first line of the CSV file (assuming it contains column headers like "year").
  if [[ $YEAR != 'year' ]]
  then
    #Line below checks the team_id of the country winner on the 'teams' table.
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #If not found
    if [[ -z $WINNER_ID ]]
    then
      #It inserts the winner country into the table 'teams'
      INSERT_WINNER_COUNTRY=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_COUNTRY == "INSERT 0 1" ]]
      then
        echo "Inserted Into Teams, $WINNER"
      else
        echo "$WINNER not inserted into table teams"
      fi
      #Line below retrieves the winner's team ID and stores it in the $WINNER_ID variable for later use when inserting the game data.
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    #Same process for Opponent team name. It checks if the OPPONENT team already exists in the "teams" table.
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #If not found
    if [[ -z $OPPONENT_ID ]]
    then
      #It inserts the opponent country into the table 'teams'
      INSERT_OPPONENT_COUNTRY=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_COUNTRY == 'INSERT 0 1' ]]
      then
        echo "Inserted Into Teams, $OPPONENT"
      else
        echo "$OPPONENT not inserted into table teams!!!"
      fi
      #Line below retrieves the opponent's team ID and stores it in the $OPPONENT_ID variable for later use when inserting the game data.
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    #The line below extracted game data from the CSV file and inserted into the games table.
    GAME_DATA=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAME_DATA == "INSERT 0 1" ]]
    then
      echo "Data Inserted Into Games Table"
    else 
      echo "Data NOT Inserted Into Games Table!!!"
    fi
  fi
done
