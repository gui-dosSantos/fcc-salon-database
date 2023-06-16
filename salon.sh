#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~"

MAIN_MENU() {
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nWelcome to our appointment scheduler, wich of the following services are you interested in?\n"
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES_AVAILABLE ]]
  then
    echo "I'm sorry, we don't have any service available."
  else
    echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Please enter a valid service number"
    else
      SERVICE_CHOSEN_EXISTS_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_CHOSEN_EXISTS_RESULT ]]
      then
        MAIN_MENU "Please choose one of the available services"
      else
        echo -e "\nPlease enter your phone number:"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # check if phone is in the customer table
        if [[ -z $CUSTOMER_NAME ]]
        then
          # if not, insert
          echo -e "\nPlease enter your name:"
          read CUSTOMER_NAME
          CUSTOMER_INSERTION=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi
        # grab customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # request a time
        echo -e "\nPlease enter a time:"
        read SERVICE_TIME
        # insert the appointment
        APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        if [[ -z $APPOINTMENT_INSERT_RESULT ]]
        then
          MAIN_MENU "Failed to schedule the appointment, please try again."
        else
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
          echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
      fi
    fi
  fi
}

MAIN_MENU