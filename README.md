# Hermes-chat-app
A simple chat app made with Flutter


Hermes is a real-time chat application which utilizes Firebase Firestore to store and receive data rapidly. While messages are currently configured to update when sent, 
it is possible to configure real-time updates while a message is still being typed. However, this feature consumes multiple writes per message and is far slower than
the conventional method. 

Hermes features an easy sign-in using your Google account, and your profile picture, username and display name are grabbed directly from Google. At this time, functionality
to change these fields in app has not been implemented. It also features a dynamic search where other users can be searched for.

Hermes comes with its own in-built chatbot named Athena. Athena works independently of Firebase and operates off of Google's Dialogflow API. She is currently only configured
to handle small talk, but these intents can be updated seamlessly without needing to update the app as all the changes take place in the Dialogflow backend. More intents should
be configured soon. 

Hermes is still in a beta state and may receive updates in the future. You can find some screenshots of the app in action down below.

