from flask import Flask,request
import socket,os
app = Flask(__name__)

@app.route('/')
def hello():
    return '<h1>Hello from Flask & k8 Request is served from host {} & Pod {}</h2>'.format(os.environ['MY_NODE_NAME'],socket.gethostname())

@app.route('/ping')
def ping():
    return 'pong'

if __name__ == "__main__":
    app.run(debug=True)