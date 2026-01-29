import requests

API_URL = "https://isitreadonlyfriday.com/api/"
OUTPUT_FILE = "readonly_friday_status.html"

response = requests.get(API_URL)
data = response.json()

readonly = data.get("readonly", False)
message = data.get("message", "Unknown status")

status_color = "#c0392b" if readonly else "#27ae60"
status_icon = "🔒" if readonly else "✏️"
title = "Read-Only Friday" if readonly else "Coding Allowed"

html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{title}</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }}
        .card {{
            background: white;
            padding: 2rem 3rem;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            text-align: center;
        }}
        h1 {{
            color: {status_color};
            margin-bottom: 0.5rem;
        }}
        p {{
            font-size: 1.2rem;
        }}
    </style>
</head>
<body>
    <div class="card">
        <h1>{status_icon} {title}</h1>
        <p>{message}</p>
    </div>
</body>
</html>
"""

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"HTML file generated: {OUTPUT_FILE}")
