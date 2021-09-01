# Chatroom_on_web

A simple LAN chatroom web app, which can be opened in any deviced with browser and you can chat with friends in the local area network. e.g. at school, at home...

Now, the repository contains the flutter project, the servers, and a built web app. 

# How to use it?
To use it, you need the web app folder and the servers.

You can find the *web app folder* "web" in the folder `.../Build html files`, or in the release session.

You can find the *server files* in the folder `.../Web&Chatroom_Servers`, or in the release session.

## Webpage server: Webpage_Server.py
+ Move the web app folder "web" in the same directory as the file "Webpage_Server.py".
+ Then set the port number of the web app server in "Webpage_Server.py"(Line 31). (by default, the port number is 23333).
+ Finally, run the python file "Webpage_Server.py", if everything is going ok, you will see "he HTTP server for the web page..." at the terminal.

## Chatroom server: Chatroom_Server.py
+ Make sure there is a json file "userInfo.json" in the same directory as the file "Chatroom_Server.py".
+ "userInfo.json" file stores all user name and password to login. You can change it and distribute specific user name and password to your friends.
+ Then set the port number of the web app server in "Webpage_Server.py"(Line 113). (by default, the port number is 1234).
+ Finally, run the python file "Webpage_Server.py", if everything is going ok, you will see "The server started at..." at the terminal.

Now, you have finished the initialization!

For client users, they should:

1. Type `host:port`("host" is the ipv4 address of the Webpage Server, 
which can be accessed in the cmd.exe with the command `ipconfig`; 
"port" is the port number which you set for the WebPage Server. e.g. `10.30.30.180:23333`) in the browser to visit the chatroom web app. (It may takes 10-20 seconds)
2. Input the Chatroom Server ipv4 address (the ipv4 address of the Chatroom Server, which can be accessed in the cmd.exe with the command `ipconfig`), 
the port number (which you set for the Chatroom Server), the user name and the corressponding password.
3. When the user log in successfully, he can send messages in the chatroom. The chatroom now only supports for one line message.
4. The user could tap top-right corner to select "exit" to leave the chatroom.

**This is only a simple chatroom server, it doesn't support any features like traceback history, etc.**
**This is only a simple flutter web app, it only provides basic functions with out errors. If you meet some error when using the web app, `refresh` might be the best choice.**
