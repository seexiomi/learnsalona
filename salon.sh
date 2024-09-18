#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Xiomi's Salon ~~~~~"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # get customer selections
  read SERVICE_ID_SELECTED

  # if service requested not a numnber 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICES_MENU "Sorry, that is not a valid service. Please choose from the following services:"
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

    # if selection not in services
    if [[ -z $SERVICE_ID ]]
    then
      # send to service menu
      SERVICES_MENU "Sorry, that is not a valid service. Please choose from the following services:"
    else
      # get customer phone
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # if no record
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # insert into customers
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # ask for appointment time
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
      echo -e "\nWhat time would you like your $SERVICE_NAME $CUSTOMER_NAME?"
      read SERVICE_TIME
      # insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES((SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'), $SERVICE_ID, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi 
  fi
}

echo -e "\nWelcome to Xiomi's Salon, how may I help you?\n"
SERVICES_MENU