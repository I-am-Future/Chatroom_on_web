import time
import json
import asyncio
import websockets

# the user info (username and password) should be stored in this json file:
userInfoFilename = 'userInfo.json'
clients = [] # in the format of (websocket, userid, address)


def encode_json(_type, _content):
    # encode the command in json format
    temp_dict = {}
    temp_dict['type'] = _type
    temp_dict['content'] = _content
    return json.dumps(temp_dict)

def decode_json(jsonString):
    # decode the command to dict
    return json.loads(jsonString)


# connect to the client and verify it
async def check_permit(websocket):
    while True:
        print(websocket)
        # print(dir(websocket))
        recv_str = await websocket.recv()
        print(recv_str)
        recv_dict = decode_json(recv_str)
        print(recv_dict)
        if recv_dict['type'] == 'trial':
            # attempt connection
            if recv_dict['userid'] in users.keys():
                if users[recv_dict['userid']] == recv_dict['pw']:
                    await websocket.send(encode_json('cmd', '/permitted'))
                    print(websocket.remote_address, 'permitted to attempt log in')
                    websocket.close_connection()
                    return True
                else:
                    await websocket.send(encode_json('cmd', '/denied'))
                    print(websocket.remote_address, 'not permitted')
            else:
                await websocket.send(encode_json('cmd', '/denied'))
                print(websocket.remote_address, 'not permitted')
                
        elif recv_dict['type'] == 'formalLogin':
            # formal connection
            if recv_dict['userid'] in users.keys():
                if users[recv_dict['userid']] == recv_dict['pw']:
                    await websocket.send(encode_json('cmd', '/permitted'))
                    print('permitted')
                    clients.append((websocket, recv_dict['userid'], websocket.remote_address[0]))
                    return True
                else:
                    await websocket.send(encode_json('cmd', '/denied'))
                    print(websocket.remote_address,'not permitted')
            else:
                await websocket.send(encode_json('cmd', '/denied'))
                print(websocket.remote_address,'not permitted')

# receive the message and then broadcast to others
async def recv_msg(websocket):
    for _ws, _userid, _addr in clients:
        if _ws == websocket:
            userid = _userid
            addr = _addr
    print('recv')
    while True:
        try:
            recv_json = await websocket.recv()
        except:
            websocket.close_connection()
            print(_userid, 'lost connection')
            break
        recv_dict = json.loads(recv_json)
        if recv_dict['type'] == 'msg':
            response_dict = {
                             'type':'msg', 
                             'time':time.strftime("%H:%M:%S", time.localtime()), 
                             'fromid': recv_dict['fromid'],
                             'content':recv_dict['content']
                            }
        print(response_dict)
        print(clients)
        disconnect_websockets = []
        # broadcast all & delete the dead clients.
        for index,client in enumerate(clients):
            try:
                await client[0].send(json.dumps(response_dict))
            except:
                disconnect_websockets.append(index)
        del response_dict
        for index in disconnect_websockets[::-1]:
            del clients[index]                           
        del disconnect_websockets
        

# main logic
async def main_logic(websocket, path):
    print(path)
    print(type(path))
    await check_permit(websocket)

    await recv_msg(websocket)

with open(userInfoFilename) as f:
    users = json.load(f)
print(users)

# 可自行更改聊天服务器端口号
# you can change the chatroom server port number
start_server = websockets.serve(main_logic, '0.0.0.0', 1234)


print('The server started at', time.strftime("%H:%M:%S", time.localtime()))
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()