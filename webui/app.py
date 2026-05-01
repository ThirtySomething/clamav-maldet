from flask import Flask, render_template, redirect
import subprocess

app = Flask(__name__)


def get_quarantine():
    try:
        out = subprocess.check_output(["maldet", "--list"]).decode()
    except Exception:
        return []

    result = []
    for line in out.split("\n"):
        if line.startswith("FILE:"):
            parts = line.split()
            qid = parts[1]
            fname = parts[-1]
            result.append({"id": qid, "file": fname})
    return result


@app.route("/")
def index():
    return render_template("index.html", quarantine=get_quarantine())


@app.route("/restore/<qid>")
def restore(qid):
    subprocess.call(["maldet", "--restore", qid])
    return redirect("/")


app.run(host="0.0.0.0", port=8888)
