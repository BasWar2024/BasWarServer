BasWarServer is the source code of the BasWar server. It uses C language to write the underlying framework and Lua language to write functional logic.
The game communication protocol uses Google Protobuf. The database uses MongoDB. Data caching uses Redis.  

Catalog description:  
ansible folder is the directory of automated deployment scripts.  
ansible/install.yml is the running environment script of the deployment project.  
ansible/start.yml is the script to start the server.  
ansible/stop.yml is the script for shutting down the server.  

robot folder is a directory of stress test scripts, which can generate a large number of robots to simulate user behaviors and perform performance tests on servers.  
robot/start.sh is the script to start the robot.  
robot/stop.sh is the script for closing the robot.  

server folder is the main logic of the BasWar server.  
server/start.sh starts the game server script.  
server/stop.sh closes the game server script.  
server/src/app/login is the login verification module, responsible for account registration, login verification, and creation of player data.  
server/src/app/center is the data center module, which is responsible for recording player briefings and synchronizing the status of all players.  
server/src/app/game is the logical server, which is responsible for accessing player data and responding to client requests.  
server/src/app/bigmap is the big map manager, responsible for managing the resource star data and recording the player's operations on the resource star.  
server/src/app/rank is the ranking module, responsible for managing the ranking data.  
server/src/app/share is the public interface layer, which is mainly used to send verification codes and synchronize blockchain information.  
server/src/common is the program base library.  
server/src/etc manages game configuration information.  

Statement:  
This project is a closed source project and does not provide deployment tutorials. The usage of this project's codes for other purposes will lead to legal responsibilities.  
