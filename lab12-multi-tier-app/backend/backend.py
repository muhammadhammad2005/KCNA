from flask import Flask, jsonify
import mysql.connector
import os
import time

app = Flask(__name__)

def get_db_connection():
    for i in range(5):
        try:
            conn = mysql.connector.connect(
                host=os.environ['DB_HOST'],
                port=int(os.environ['DB_PORT']),
                database=os.environ['DB_NAME'],
                user=os.environ['DB_USER'],
                password=os.environ['DB_PASSWORD']
            )
            return conn
        except Exception as e:
            print(f"Database connection attempt failed: {e}")
            time.sleep(5)
    return None

@app.route('/api/health')
def health():
    return jsonify({'status':'healthy','service':'backend'})

@app.route('/api/data')
def data():
    conn = get_db_connection()
    if conn:
        cur = conn.cursor()
        cur.execute('SELECT VERSION()')
        v = cur.fetchone()
        conn.close()
        return jsonify({'message':'Backend connected to database','db_version':v[0]})
    return jsonify({'error':'DB connection failed'}),500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ['APP_PORT']))

