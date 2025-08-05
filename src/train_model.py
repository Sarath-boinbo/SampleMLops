# src/train_model.py
import argparse
import pandas as pd
import mlflow
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import f1_score, accuracy_score, precision_score, recall_score

def train_model(train_path: str, val_path: str, model_name: str):
    """Loads data, trains a model, and logs experiment to MLflow."""

    # --- MLflow Setup ---
    # Make sure your MLFLOW_TRACKING_URI is set as an environment variable
    mlflow.set_experiment("churn-prediction")

    print(f"Loading data from {train_path} and {val_path}")
    train_df = pd.read_csv(train_path)
    val_df = pd.read_csv(val_path)

    # Drop customerID as it's not a feature
    train_df = train_df.drop("customerID", axis=1, errors='ignore')
    val_df = val_df.drop("customerID", axis=1, errors='ignore')

    # Separate features (X) and target (y)
    X_train = train_df.drop('Churn', axis=1)
    y_train = train_df['Churn']
    X_val = val_df.drop('Churn', axis=1)
    y_val = val_df['Churn']

    # --- MLflow Experiment Run ---
    with mlflow.start_run() as run:
        print(f"Starting MLflow Run: {run.info.run_id}")

        # --- Model Training ---
        model = LogisticRegression(max_iter=1000, random_state=42)
        model.fit(X_train, y_train)

        # --- Evaluation ---
        y_pred = model.predict(X_val)
        accuracy = accuracy_score(y_val, y_pred)
        f1 = f1_score(y_val, y_pred)
        precision = precision_score(y_val, y_pred)
        recall = recall_score(y_val, y_pred)

        print(f"Validation F1 Score: {f1:.4f}")

        # --- Logging to MLflow ---
        mlflow.log_param("model_type", "LogisticRegression")

        mlflow.log_metric("val_accuracy", float(accuracy))
        mlflow.log_metric("val_f1_score", float(f1))
        mlflow.log_metric("val_precision", float(precision))
        mlflow.log_metric("val_recall", float(recall))

        # Log and register the model in the MLflow Model Registry
        mlflow.sklearn.log_model( # type: ignore
            sk_model=model,
            artifact_path="model",
            registered_model_name=model_name
        )
        print(f"Model logged and registered as '{model_name}'")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Model Training for Churn Prediction")
    parser.add_argument("--train-path", type=str, required=True, help="Path to the training data CSV")
    parser.add_argument("--val-path", type=str, required=True, help="Path to the validation data CSV")
    parser.add_argument("--model-name", type=str, default="telco-churn-model", help="Name for the registered model in MLflow")
    args = parser.parse_args()

    train_model(args.train_path, args.val_path, args.model_name)