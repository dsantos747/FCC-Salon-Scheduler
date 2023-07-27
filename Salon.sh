#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Danny's Sexy Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
        echo -e "\n$1"
  fi

  # List available Services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Request user input for chosen service
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Check for valid service selection
  if [[ -z $SERVICE_ID_SELECTED  ]]
  then
    # Not a valid service selection
    MAIN_MENU "Please choose a valid service."
  else
    # get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI see you're a new customer. What's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # get service time
    echo -e "\nPerfect, thanks for popping in $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g'). What time would you like your appointment?"
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Appointment confirmation
    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $(echo $SERVICE_SELECTED | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  fi
}

MAIN_MENU "Welcome to Danny's Sexy Salon, how can I help you?"