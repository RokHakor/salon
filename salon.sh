#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Welcome to salon ~~\n"

MAIN_MENU() {
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHello, please choose a service?\n"

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read ID PIPE SERVICE
  do
    echo -e "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  CHOOSEN_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $CHOOSEN_SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service."
  else
    SET_TIME $CHOOSEN_SERVICE_NAME $SERVICE_ID_SELECTED
  fi

}

SET_TIME() {

  CHOOSEN_SERVICE_NAME=$1
  SERVICE_ID_SELECTED=$2

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME') ")

  fi

  echo -e "\nWhat time would you like your $CHOOSEN_SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' ")"

  INSERT_FINAL_DATA=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ")


  echo -e "\nI have put you down for a $CHOOSEN_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
