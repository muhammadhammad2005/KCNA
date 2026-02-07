from flask import Flask, jsonify
import mysql.connector
import os
import time
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

def get_db_connection():
    for i in range(5):
        try:
            conn = mysql.connector.connect(
                host=os.environ.get('DB_HOST'),
                port=int(os.environ.get('DB_PORT')),
                database=os.environ.get('DB_NAME'),
                user=os.environ.get('DB_USER'),
                password=os.environ.get('DB_PASSWORD'),
                connection_timeout=5
            )
            return conn
        except Exception as e:
            logging.error(f"Database connection attempt {i+1} failed: {e}")
            time.sleep(3)
    return None

@app.route('/api/health')
def health():
    conn = get_db_connection()
    if conn:
        conn.close()
        return jsonify({'status':'healthy','service':'backend','db':'connected'})
    return jsonify({'status':'degraded','service':'backend','db':'disconnected'}), 503

@app.route('/api/data')
def data():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error':'Database connection failed'}), 500

    try:
        cur = conn.cursor()
        cur.execute('SELECT VERSION()')
        v = cur.fetchone()
        return jsonify({
            'message':'Backend connected to database',
            'db_version': v[0]
        })
    finally:
        conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('APP_PORT', 5000)))

