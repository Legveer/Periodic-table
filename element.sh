#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Get the input argument
INPUT=$1

# Check if an argument was provided
if [[ -z $INPUT ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Determine the query condition based on the input type
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  # Input is an atomic number
  QUERY="SELECT elements.atomic_number, elements.symbol, elements.name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type 
         FROM elements 
         INNER JOIN properties ON elements.atomic_number = properties.atomic_number 
         INNER JOIN types ON properties.type_id = types.type_id 
         WHERE elements.atomic_number = $INPUT;"
elif [[ ${#INPUT} -le 2 ]]; then
  # Input is a symbol
  QUERY="SELECT elements.atomic_number, elements.symbol, elements.name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type 
         FROM elements 
         INNER JOIN properties ON elements.atomic_number = properties.atomic_number 
         INNER JOIN types ON properties.type_id = types.type_id 
         WHERE elements.symbol = '$INPUT';"
else
  # Input is a name
  QUERY="SELECT elements.atomic_number, elements.symbol, elements.name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type 
         FROM elements 
         INNER JOIN properties ON elements.atomic_number = properties.atomic_number 
         INNER JOIN types ON properties.type_id = types.type_id 
         WHERE elements.name = '$INPUT';"
fi

# Execute the query
DATA=$($PSQL "$QUERY")

# Check if any data was returned
if [[ -z $DATA ]]; then
  echo "I could not find that element in the database."
else
  # Parse and display the data
  echo "$DATA" | while read ATOMIC_NUMBER BAR SYMBOL BAR NAME BAR MASS BAR MELTING BAR BOILING BAR TYPE; do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
