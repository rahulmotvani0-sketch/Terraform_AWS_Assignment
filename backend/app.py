import os
import socket
from datetime import datetime
from flask import Flask, request, jsonify, render_template_string
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# In-memory store for submissions processed by Flask
submissions_store = []

@app.route("/")
def helloworld():
    """Root endpoint matching the reference repository structure."""
    hostname = socket.gethostname()
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>DevOps Flask Backend Service</title>
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px; background: #f8fafc; color: #1e293b; }}
            .card {{ background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); max-width: 600px; }}
            h1 {{ color: #0284c7; margin-top: 0; }}
            code {{ background: #e2e8f0; padding: 2px 6px; border-radius: 4px; font-size: 0.9em; }}
            .badge {{ display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; background: #22c55e; color: white; }}
        </style>
    </head>
    <body>
        <div class="card">
            <span class="badge">RUNNING</span>
            <h1>Flask Microservice Active</h1>
            <p>Welcome to the DevOps Assignment 5 Flask backend.</p>
            <ul>
                <li><strong>Container ID:</strong> <code>{hostname}</code></li>
                <li><strong>Endpoint:</strong> <code>POST /process</code> (Handles Node.js/Express submissions)</li>
                <li><strong>Endpoint:</strong> <code>GET /submissions</code> (List recorded entries)</li>
                <li><strong>Endpoint:</strong> <code>GET /health</code> (Container health check)</li>
            </ul>
        </div>
    </body>
    </html>
    """
    return render_template_string(html_content)

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint for Docker Compose / Orchestration."""
    return jsonify({
        "status": "healthy",
        "service": "flask-backend",
        "container_id": socket.gethostname(),
        "timestamp": datetime.now().isoformat()
    }), 200

@app.route("/process", methods=["POST"])
def process():
    """
    Handles form submission from the Node.js/Express frontend.
    Accepts both application/json and application/x-www-form-urlencoded data.
    """
    data = request.get_json(silent=True) or request.form.to_dict()

    if not data or "name" not in data or not data["name"]:
        return jsonify({
            "status": "error",
            "message": "Missing required field: 'name'"
        }), 400

    name = data.get("name")
    email = data.get("email", "Not provided")
    course = data.get("course", "DevOps & Cloud Engineering")
    message = data.get("message", "")
    priority = data.get("priority", "Medium")

    processed_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    container_id = socket.gethostname()

    record = {
        "id": len(submissions_store) + 1,
        "name": name,
        "email": email,
        "course": course,
        "message": message,
        "priority": priority,
        "processed_at": processed_time,
        "container_id": container_id
    }
    submissions_store.append(record)

    # Reference structure: f"Hello {data['name']}! Data received successfully."
    response_payload = {
        "status": "success",
        "message": f"Hello {name}! Data received and processed successfully by Flask backend.",
        "data": record,
        "processed_at": processed_time,
        "server_info": {
            "container_id": container_id,
            "framework": "Flask 3.1.3 (Python 3.11)",
            "total_processed": len(submissions_store)
        }
    }

    print(f"[Flask Backend] Processed entry #{record['id']} for {name} ({email}) at {processed_time}")
    return jsonify(response_payload), 200

@app.route("/submissions", methods=["GET"])
def get_submissions():
    """Returns all submissions stored in the Flask backend session."""
    return jsonify({
        "status": "success",
        "total": len(submissions_store),
        "submissions": list(reversed(submissions_store))
    }), 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)

