# TFG_azure_project

## Belgium traffic sensor data

This project is about processing the data retrieved from IOT sensors in Belgium. These sensors send some important information about
the traffic by minute. As the number of sensor is quite big, the data for each sensor will be retrieved by 5 minutes instead of by minute.

We will have 2 different feeds to process:

- The first feed contains data about the unique ID of each sensor, location, 

- The second feed contains data about the last update of the sensor, how much vehicles has passed by that road, average speed, etc

What the system will do it is to process the sensors data to see what sensors are working right now. We will be able to see a MAP with the different sensors
and we will see what sensors are in a good state and which are not.

## Branchs

There are you differents branchs:

 - **Develop branch:** This branch is called "tfg/develop". In this branch I am going to build the DEV environment of the project, where there will be the new development.
 - **Production branch:** This branch is called "tfg/master". This branch is what will contain the PROD environment of the project, that it is the actual working system.

