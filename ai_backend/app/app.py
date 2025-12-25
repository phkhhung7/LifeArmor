from flask import Flask
from flask_cors import CORS
from ai_chat import predict_bp
from ai_chat import train_knn_bp

app = Flask(__name__)
CORS(app)

# Đăng ký blueprints
app.register_blueprint(train_knn_bp, url_prefix='/api')
app.register_blueprint(predict_bp, url_prefix='/api')

if __name__ == "__main__":
    app.run(debug=True)