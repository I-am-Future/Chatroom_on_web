import socket
import threading
import o

def handle_client(c,addr):
    print(addr, "connected")

    with c:
        request = c.recv(1024)
        headers = request.split(b"\r\n")
        file = headers[0].split()[1].decode()
        if file == "/":
            file = "/index.html"
        try:
            with open(WEBROOT + file, "rb") as f:
                content = f.read()
            response = b"HTTP/1.0 200 OK\r\n\r\n" + content    
        except FileNotFoundError:
            response = b"HTTP/1.0 404 NOT FOUND\r\n\r\nFile not found!"   
        c.sendall(response)

if __name__ == '__main__':
    WEBROOT = os.path.dirname(__file__)
    WEBROOT = os.path.join(WEBROOT, 'web')
    print('The HTTP server for the web page has been successfully started')
    print('the root of the web file is:', WEBROOT)
    
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        # 可自行更改网页服务器端口号
        # you can change the web page server port number
        s.bind(("0.0.0.0", 23333))
        s.listen()

        while True:
            c, addr = s.accept()
            t = threading.Thread(target=handle_client, args=(c, addr))
            t.start()
