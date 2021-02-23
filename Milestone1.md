# Milestone 1 - triv.io 
## Trivia App 
____________________________________________
### Manprit Heer ![Screenshot](/profilePictures/Manprit_189E.JPG | width= 25)
	 Github: @mamkh27
### Donald Lieu
	 Github: @de-Blaxe
### Roberto Lozano
	 Github: @robertolozano
### Jessica Wu
	 Github: @innkuika
### Jessica Ma
	 Github: @ma-jessica

### 1. Screen Designs: https://www.figma.com/file/Ff3cBXe8WKmy5hnkCPfrZN/triv.io?node-id=56%3A82
____________________________________________________

### 2. Third Party Libraries: 
Firebase Authentication/Login
Facebook Authentication/Login
Google Authentication/Login
Apple Authentication/Login
SwiftFortuneWheel
____________________________________________________

### 3. Server Support for App/APIs to build: 
No external server file 
Database: Google Firebase 
____________________________________________________

### 4. List of Models: 
Questions Model 
Prompt
Options
Solution Key
User Model
Name
Number of Wins
Game Instance/State Model
Displays Current State
____________________________________________________

### 5. List of View Controllers to Implement: 
	Launch Screen
	Log-In Screen
	Send Code to User Screen (Join Game)
	User Verifies Game Code Screen
	Pick 3 Categories Screen 
	Question & Options Screen
	Who Do You Want to Play With Screen
	Matching with Random Screen
	Spin Screen Screen
	Waiting for Other Player Screen
	Winning Screen 
	Question Submitted Screen
	Enter Question Here Screen
	Select Tags Screen
	Friend Request Screen
	Enter Friend Code Screen
	Leaderboard Screen
	Settings/User Screen

#### Protocols/Delegates/Variables in Use: 
* Game Instance/State Protocol
* Question Protocol
* User Protocol

#### View Controller Communication: 
*See Screen Design for Communication*
*Game Variables:*
* passing user information
* refreshing/updating game state 
* question 
* categories chosen (6) 
____________________________________________________
### 6. Testing Plan:
#### 1. Log In:
	* How long does it take a user to complete the authentication step?
	* Are the authentication methods that we currently provide sufficient? 
	* Is there an alternate authentication method that a significant portion of users would prefer to have as an option?

#### 2. Start/Join a Game:
	* On a scale of 1-5, how easy was it to start a new game?
	* On a scale of 1-5, how easy was it to join an existing game?
	* On a scale of 1-5, how would you rate the look and feel of this interface?

#### 3. Gameplay:
	* On a scale of 1-5, how easy was it to understand the game mechanics?
	* On a scale of 1-5, how fun and interesting were the trivia questions that you were given?
	* On a scale of 1-5, how engaging was the gameplay overall?
	* On a scale of 1-5, how would you rate the look and feel of this interface?

#### 4. Contribute Questions:
	* On a scale of 1-5, how easy was it to create and tag new questions?
	* On a scale of 1-5, how would you rate the look and feel of this interface?

#### 5. User Profile:
	* On a scale of 1-5, how easy was it to locate this page?
	* On a scale of 1-5, how easy was it to update your profile information?
	* On a scale of 1-5, how would you rate the look and feel of this interface?

#### 6. Leaderboard:
	* On a scale of 1-5, how easy was it to locate this page?
	* On a scale of 1-5, how would you rate the look and feel of this interface?

#### 7. Overall:
	* On a scale of 1-5, how easy was it to navigate the app?
	* How often do you see yourself coming back to this app? 
		* 	Never 
		* 	Once a week
		* 	Once every few days 
		* 	Once a day 
		* 	Multiple times a day

____________________________________________________

### 7. Timeline / Week long tasks: 
Finished So Far:
* Basic Logic for Questions & Spinwheels
* Protocols/Model files initiated and filled 
* MVP UI Done 

### Push App to App Store DATE: 03/06/21
1. Implement rest of VCs
* Coin Features
* Shop for Avatar Customizations/Accessories
* Buy a new Category
* Coin Awards via Streaks and Referrals 
	Personalized Avatar Feature 
2. Add more questions (50+) to Each Category 
3. Friend Implementation
4. Leaderboard 
5. Game Verification Code for Joining Game
6. Notification Pop-Up Implementation


Initial Push of MVP to App Store DATE: 02/27/21
Let User Create Questions/Categories

### Deadline: 02/22/21
* Create Database with Updated Schema (Manprit) *FINISHED*
* Connect Database to Server Side of iOS *FINISHED*
	* pod Firebase (Finished)
	* fetch database, connect with models [Manprit/Donald] *FINISHED*
	* update(), delete(), create() Documentation [Manprit/Donald] *FINISHED*

### Deadline: 02/25/21-02/26/21
* Polish UI [Jessica W] *P3*
* Further Database/Model Installation [Manprit/Donald] *P1*
* App Landing/Home Page [Jessica M] *P2*
* End of 2/26/21 Create Pages/Slide [Manprit] *P3*
* Implement Apple Login/Authentication (Roberto) *P1*
* Website (Landing Page) [Roberto] [Finished (For now)]
	* Privacy block 
	* Logo + App Description + Link to App (App Store button) 
* Randomize Bot Data (Finished) 
* Create Categories/Questions (7/7 Finished) (Everyone)
	1. Science & Tech DONE
	2. Video Games DONE
	3. History
	4. Pop Culture → Memes,  Catch Phrases, TV Shows, 
	5. UC Davis
	6. Art → Music/Paintings/Graffiti 
	7. Sports
* Use Protocols to Connect Game Logic()
* 5 Questions Per Category 
 	* 4 answers per Question

