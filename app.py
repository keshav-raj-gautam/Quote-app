from flask import Flask, jsonify
import random

app = Flask(__name__)

quotes = [
    "Believe in yourself!",
    "Keep pushing forward.",
    "Stay positive, work hard, make it happen.",
    "Success is not final; failure is not fatal.",
    "Your only limit is your mind."
]

@app.route("/quote")
def get_quote():
    return jsonify({"quote": random.choice(quotes)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
